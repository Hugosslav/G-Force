import SwiftUI

/// The grid + ball g-meter. Takes raw-ish lateral/longitudinal values (already
/// EMA-smoothed upstream in MotionManager) and animates the ball toward them —
/// fast when g increases, slower when returning to center, so a spike has a
/// moment to actually register visually instead of springing back instantly.
struct GForceMeterView: View {
    let lateralG: Double
    let longitudinalG: Double

    private let maxG = 1.5
    private let dotSize: CGFloat = 30

    /// What's actually rendered — animated toward (lateralG, longitudinalG)
    /// rather than tracking them directly.
    @State private var displayedLateralG: Double = 0
    @State private var displayedLongitudinalG: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2

            let clampedX = max(-maxG, min(maxG, displayedLateralG))
            let clampedY = max(-maxG, min(maxG, displayedLongitudinalG))

            let xOffset = (clampedX / maxG) * (radius - dotSize / 2)
            let yOffset = -(clampedY / maxG) * (radius - dotSize / 2)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.secondary, lineWidth: 2)

                ForEach([1.0 / 3, 2.0 / 3], id: \.self) { fraction in
                    RoundedRectangle(cornerRadius: 24 * fraction)
                        .stroke(.secondary.opacity(0.35), lineWidth: 1)
                        .scaleEffect(fraction)
                }

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(width: 1)

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(height: 1)

                gridLabel("0.5g").position(x: radius + (radius / 3) + 16, y: radius)
                gridLabel("1.0g").position(x: radius + (radius * 2 / 3) + 16, y: radius)
                gridLabel("1.5g").position(x: size - 16, y: radius)

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: xOffset, y: yOffset)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            displayedLateralG = lateralG
            displayedLongitudinalG = longitudinalG
        }
        .onChange(of: lateralG) { _, _ in updateDisplayedValues() }
        .onChange(of: longitudinalG) { _, _ in updateDisplayedValues() }
    }

    private func updateDisplayedValues() {
        let previousMagnitude = (displayedLateralG * displayedLateralG
            + displayedLongitudinalG * displayedLongitudinalG).squareRoot()
        let newMagnitude = (lateralG * lateralG + longitudinalG * longitudinalG).squareRoot()

        // Slower only on the way back down to 0g — fast/immediate on the way up,
        // so a spike is visible before it eases back rather than snapping back.
        let isReturningToCenter = newMagnitude < previousMagnitude
        let duration = isReturningToCenter ? 0.45 : 0.1

        withAnimation(.easeOut(duration: duration)) {
            displayedLateralG = lateralG
            displayedLongitudinalG = longitudinalG
        }
    }

    private func gridLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    GForceMeterView(lateralG: 0.3, longitudinalG: -0.6)
        .frame(width: 280, height: 280)
        .padding()
}
