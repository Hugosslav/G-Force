import Foundation

struct GSample: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let xG: Double
    let yG: Double
    let zG: Double

    init(id: UUID = UUID(), timestamp: Date = Date(), xG: Double, yG: Double, zG: Double) {
        self.id = id
        self.timestamp = timestamp
        self.xG = xG
        self.yG = yG
        self.zG = zG
    }

    var lateralG: Double { xG }
    var longitudinalG: Double { -yG }

    var totalG: Double {
        sqrt(xG * xG + yG * yG + zG * zG)
    }
}