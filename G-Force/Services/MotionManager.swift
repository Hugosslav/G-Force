import CoreMotion
import Foundation
import Combine

/// Wraps CMMotionManager and resolves raw device-frame acceleration into
/// car-relative lateral (cornering) / longitudinal (braking-accel) g.
///
/// Two problems have to be solved to get there, and this is the most fragile
/// part of the whole app — expect to need to tune it against a real car:
///
/// 1. The phone's mounting tilt. Fixed by reading CMDeviceMotion with the
///    `.xMagneticNorthZVertical` reference frame, which keeps Z aligned with
///    gravity regardless of how the phone sits in its mount, and orients the
///    horizontal X/Y plane relative to magnetic north.
///
/// 2. Which way is "forward". The phone doesn't know the car's heading just
///    because it's mounted — X/Y from step 1 are north/east-ish, not
///    forward/lateral. This class rotates those into car axes using GPS
///    course-over-ground (supplied externally via `updateHeading`), since
///    magnetic north alone is unreliable inside a car (metal interference).
///    GPS course is only meaningful above walking speed, so the caller
///    should hold the last good course at low speed rather than feed in noise.
final class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    /// Raw (unfiltered) values — use these for anything that gets stored/scored.
    @Published private(set) var lateralG = 0.0
    @Published private(set) var longitudinalG = 0.0
    @Published private(set) var verticalG = 0.0

    /// Lightly smoothed (exponential moving average) — display only, never stored.
    /// Keeps the live ball readable without lying about the underlying data.
    @Published private(set) var smoothedLateralG = 0.0
    @Published private(set) var smoothedLongitudinalG = 0.0

    @Published private(set) var isRunning = false

    /// Current heading-of-travel, in radians, used to rotate the north/east-ish
    /// horizontal acceleration into car forward/lateral axes. Supplied by
    /// LocationService. Defaults to 0 (i.e. "north = forward") until GPS course
    /// is available, so expect the split to be wrong for the first few seconds
    /// of any drive.
    private var headingRadians: Double = 0

    private let smoothingAlpha = 0.28

    var currentSample: GSample {
        GSample(
            lateralG: lateralG,
            longitudinalG: longitudinalG,
            verticalG: verticalG
        )
    }

    func updateHeading(radians: Double) {
        headingRadians = radians
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 20.0
        isRunning = true

        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: .main
        ) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.process(motion)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
    }

    private func process(_ motion: CMDeviceMotion) {
        let a = motion.userAcceleration
        let r = motion.attitude.rotationMatrix

        // Rotate device-frame acceleration into the reference frame (Z vertical,
        // X toward magnetic north, Y toward magnetic east).
        let northG = r.m11 * a.x + r.m12 * a.y + r.m13 * a.z
        let eastG = r.m21 * a.x + r.m22 * a.y + r.m23 * a.z
        let vertical = r.m31 * a.x + r.m32 * a.y + r.m33 * a.z

        // Rotate north/east into forward/lateral using the current heading of travel.
        let cosH = cos(headingRadians)
        let sinH = sin(headingRadians)
        let forward = northG * cosH + eastG * sinH
        let right = eastG * cosH - northG * sinH

        lateralG = right
        longitudinalG = forward
        verticalG = vertical

        smoothedLateralG += (lateralG - smoothedLateralG) * smoothingAlpha
        smoothedLongitudinalG += (longitudinalG - smoothedLongitudinalG) * smoothingAlpha
    }
}
