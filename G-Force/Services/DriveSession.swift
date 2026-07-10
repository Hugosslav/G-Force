import Combine
import CoreLocation
import Foundation

/// Orchestrates a single drive recording: starts/stops the sensors, feeds GPS
/// course into MotionManager for heading correction, accumulates samples and
/// distance, and produces the finished Drive record on stop.
final class DriveSession: ObservableObject {
    @Published private(set) var isRecording = false

    /// Raw (unfiltered) running stats for the live KPI bar.
    @Published private(set) var livePeakG: Double = 0
    @Published private(set) var liveRMSG: Double = 0

    private let motionManager: MotionManager
    private let locationService: LocationService

    private var samples: [GSample] = []
    private var sumOfSquares: Double = 0

    private var recordingStartDate: Date?
    private var lastLocation: CLLocation?
    private var distanceMeters: Double = 0

    private var cancellables = Set<AnyCancellable>()
    private var sampleTimer: AnyCancellable?

    init(motionManager: MotionManager, locationService: LocationService) {
        self.motionManager = motionManager
        self.locationService = locationService

        locationService.$currentCourseDegrees
            .sink { [weak self] _ in
                guard let self else { return }
                self.motionManager.updateHeading(radians: self.locationService.headingRadians)
            }
            .store(in: &cancellables)
    }

    var smoothedLateralG: Double { motionManager.smoothedLateralG }
    var smoothedLongitudinalG: Double { motionManager.smoothedLongitudinalG }
    var currentHorizontalG: Double {
        (motionManager.lateralG * motionManager.lateralG
            + motionManager.longitudinalG * motionManager.longitudinalG).squareRoot()
    }

    /// Same provisional formula as Drive.score, computed live off the running
    /// peak/RMS so the skill icon can update during the drive, not just after.
    var liveScore: Double {
        liveRMSG + 0.5 * max(0, livePeakG - liveRMSG)
    }

    func start() {
        samples = []
        sumOfSquares = 0
        distanceMeters = 0
        lastLocation = nil
        livePeakG = 0
        liveRMSG = 0
        recordingStartDate = Date()
        isRecording = true

        motionManager.start()
        locationService.start()
        locationService.onLocationUpdate = { [weak self] location in
            self?.handle(location)
        }

        // Sample at a fixed 20Hz rather than tying storage to every sensor
        // callback — keeps stored-sample resolution predictable and bounded.
        sampleTimer = Timer.publish(every: 1.0 / 20.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recordSample()
            }
    }

    func stop() -> Drive? {
        sampleTimer?.cancel()
        sampleTimer = nil
        motionManager.stop()
        locationService.stop()
        locationService.onLocationUpdate = nil
        isRecording = false

        guard let startDate = recordingStartDate, !samples.isEmpty else {
            recordingStartDate = nil
            return nil
        }

        let endDate = Date()
        let duration = endDate.timeIntervalSince(startDate)
        let avgSpeed = duration > 0 ? distanceMeters / duration : nil

        let drive = Drive(
            name: "Drive on \(startDate.formatted(date: .abbreviated, time: .shortened))",
            startDate: startDate,
            endDate: endDate,
            samples: samples,
            distanceMeters: distanceMeters,
            avgSpeedMPS: avgSpeed
        )

        recordingStartDate = nil
        return drive
    }

    private func recordSample() {
        let sample = GSample(
            lateralG: motionManager.lateralG,
            longitudinalG: motionManager.longitudinalG,
            verticalG: motionManager.verticalG,
            speedMPS: locationService.currentSpeedMPS
        )
        samples.append(sample)

        sumOfSquares += sample.horizontalG * sample.horizontalG
        livePeakG = max(livePeakG, sample.horizontalG)
        liveRMSG = (sumOfSquares / Double(samples.count)).squareRoot()
    }

    private func handle(_ location: CLLocation) {
        defer { lastLocation = location }
        guard let last = lastLocation else { return }
        // Ignore GPS jitter while stationary so distance doesn't creep upward
        // while parked or stopped at a light.
        let delta = location.distance(from: last)
        if location.speed > 0.5 {
            distanceMeters += delta
        }
    }
}
