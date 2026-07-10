import SwiftUI

/// The single fixed-position, fixed-size button used at the bottom of Home
/// (green "Start Drive"), the Live screen (red "Stop Drive"), and the Detail
/// sheet (grey "Close"). Defined once so all three are guaranteed to share
/// the exact same slot and dimensions rather than drifting apart over time.
struct BottomActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

extension BottomActionButton {
    static let startColor = Color.green
    static let stopColor = Color.red
    static let closeColor = Color.gray
}
