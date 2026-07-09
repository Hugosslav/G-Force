import CoreLocation
import Foundation

/// Wraps CLLocationManager. Publishes live speed/course for MotionManager's
/// heading correction, and hands raw locations to DriveSession so it can
/// accumulate distance for the drive being recorded.
final class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published private(set) var currentSpeedMPS: Double = 0
    /// Degrees, 0-360, true north. Held at its last good value below
    /// `minimumCourseSpeed` since GPS course is noise/meaningless near-stationary.
    @Published private(set) var currentCourseDegrees: Double = 0
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// Fires on every new location while a delegate consumer (DriveSession) is listening.
    var onLocationUpdate: ((CLLocation) -> Void)?

    /// Below this speed, GPS course is too noisy to trust as heading-of-travel.
    private let minimumCourseSpeed: CLLocationSpeed = 2.5 // ~5.5 mph

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        locationManager.startUpdatingLocation()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
    }

    var headingRadians: Double {
        currentCourseDegrees * .pi / 180
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentSpeedMPS = max(0, location.speed)

        if location.speed >= minimumCourseSpeed, location.course >= 0 {
            currentCourseDegrees = location.course
        }

        onLocationUpdate?(location)
    }
}
