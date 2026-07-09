import Foundation

struct RecordedRun: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let startDate: Date
    let endDate: Date
    let samples: [GSample]

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var peakTotalG: Double {
        samples.map(\.totalG).max() ?? 0
    }
}