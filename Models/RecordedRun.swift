struct RecordedRun: Identifiable, Codable {
    let id: UUID
    var name: String
    let startDate: Date
    let endDate: Date
    let samples: [GSample]
}