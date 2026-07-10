import Foundation

/// A single instantaneous g-force reading, already resolved into car-relative axes
/// (see `MotionManager` for how lateral/longitudinal are derived from the raw sensor).
struct GSample: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date

    /// Cornering g. Positive = rightward.
    let lateralG: Double
    /// Braking/acceleration g. Positive = accelerating forward, negative = braking.
    let longitudinalG: Double
    /// Vertical g (bumps, road surface). Not used in scoring by default.
    let verticalG: Double

    /// Speed over ground at the moment of this sample, if GPS was available. Meters/second.
    let speedMPS: Double?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        lateralG: Double,
        longitudinalG: Double,
        verticalG: Double,
        speedMPS: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.lateralG = lateralG
        self.longitudinalG = longitudinalG
        self.verticalG = verticalG
        self.speedMPS = speedMPS
    }

    /// Magnitude of g-force in the horizontal plane (cornering + braking/accel combined).
    /// This is the primary "comfort" signal — it deliberately excludes vertical g, since
    /// vertical bumps reflect road surface quality, not driving smoothness.
    var horizontalG: Double {
        (lateralG * lateralG + longitudinalG * longitudinalG).squareRoot()
    }

    /// Full 3-axis magnitude, kept for completeness / future use.
    var totalG: Double {
        (lateralG * lateralG + longitudinalG * longitudinalG + verticalG * verticalG).squareRoot()
    }
}
