import Foundation

enum Formatters {
    static func gForce(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2))) + " G"
    }

    static func duration(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        return "\(minutes)m \(remainingSeconds)s"
    }
}