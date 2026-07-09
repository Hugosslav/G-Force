import CoreMotion
import Foundation

@Observable
final class MotionManager {
    private let motionManager = CMMotionManager()

    var xG: Double = 0
    var yG: Double = 0
    var zG: Double = 0

    var totalG: Double {
        sqrt(xG * xG + yG * yG + zG * zG)
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self, let motion else { return }

            self.xG = motion.userAcceleration.x
            self.yG = motion.userAcceleration.y
            self.zG = motion.userAcceleration.z
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}