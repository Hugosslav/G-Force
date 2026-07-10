import Foundation

enum Formatters {
    static func gForce(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2))) + " G"
    }

    /// Score is a provisional formula (see Drive.score) — real number now,
    /// no more "—" placeholder, but still worth keeping as its own formatter
    /// since the precision/rounding will likely change with the real model.
    static func score(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }

    static func duration(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)m \(remainingSeconds)s"
    }

    /// Whole-minutes-only duration for KPI cards ("12 min") — seconds are too
    /// granular for that context.
    static func durationMinutes(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes) min"
    }

    /// Short date, no time ("May 17") — used where a full timestamp is too much.
    static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    /// Time only, no seconds ("10:35").
    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
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
