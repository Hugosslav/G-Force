import SwiftUI

/// A user-named, color-tagged route (e.g. "Home to Office"). Assigned to a Drive
/// manually after the drive ends — there is no automatic route/trip matching yet.
struct Route: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    /// Stored as a hex string ("#RRGGBB") since SwiftUI.Color isn't Codable.
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex)
    }
}

extension Color {
    /// Small fixed palette offered when creating a new route, chosen to stay
    /// visually distinct from one another at a glance.
    static let routePalette: [String] = [
        "#FF3B30", // red
        "#FF9500", // orange
        "#FFCC00", // yellow
        "#34C759", // green
        "#00C7BE", // teal
        "#007AFF", // blue
        "#5856D6", // indigo
        "#AF52DE"  // purple
    ]

    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
