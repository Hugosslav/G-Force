import CoreMotion
import Foundation

final class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var xG = 0.0
    @Published var yG = 0.0
    @Published var zG = 0.0
    @Published var isRunning = false

    var lateralG: Double { xG }
    var longitudinalG: Double { -yG }

    var totalG: Double {
        sqrt(xG * xG + yG * yG + zG * zG)
    }

    var currentSample: GSample {
        GSample(xG: xG, yG: yG, zG: zG)
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        isRunning = true

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            self.xG = motion.userAcceleration.x
            self.yG = motion.userAcceleration.y
            self.zG = motion.userAcceleration.z
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
    }
}