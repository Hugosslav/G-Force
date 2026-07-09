import Foundation

enum Formatters {
    static func gForce(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2))) + " G"
    }

    /// Score is a placeholder until the comfort-scoring model is built.
    /// Always render nil as "—", never fabricate a number.
    static func score(_ value: Double?) -> String {
        guard let value else { return "—" }
        return value.formatted(.number.precision(.fractionLength(1)))
    }

    static func duration(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)m \(remainingSeconds)s"
    }

    static func distance(_ meters: Double?) -> String {
        guard let meters else { return "—" }
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }

    static func speed(_ metersPerSecond: Double?) -> String {
        guard let metersPerSecond else { return "—" }
        let measurement = Measurement(value: metersPerSecond, unit: UnitSpeed.metersPerSecond)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .general))
    }
}
