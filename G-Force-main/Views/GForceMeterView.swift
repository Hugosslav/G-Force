import SwiftUI

/// The grid + ball g-meter. Takes already-smoothed lateral/longitudinal values —
/// this view does no filtering itself, it just renders whatever it's given.
struct GForceMeterView: View {
    let lateralG: Double
    let longitudinalG: Double

    private let maxG = 1.5

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            let dotSize: CGFloat = 22

            let clampedX = max(-maxG, min(maxG, lateralG))
            let clampedY = max(-maxG, min(maxG, longitudinalG))

            let xOffset = (clampedX / maxG) * (radius - dotSize / 2)
            let yOffset = -(clampedY / maxG) * (radius - dotSize / 2)

            ZStack {
                // Grid rings at 0.5g, 1.0g, 1.5g
                ForEach([1.0 / 3, 2.0 / 3, 1.0], id: \.self) { fraction in
                    Circle()
                        .stroke(.secondary.opacity(0.35), lineWidth: 1)
                        .scaleEffect(fraction)
                }

                Circle()
                    .stroke(.secondary, lineWidth: 2)

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(width: 1)

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(height: 1)

                gridLabel("0.5g")
                    .position(x: radius + (radius / 3) + 14, y: radius)
                gridLabel("1.0g")
                    .position(x: radius + (radius * 2 / 3) + 14, y: radius)
                gridLabel("1.5g")
                    .position(x: size - 14, y: radius)

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: xOffset, y: yOffset)
                    .animation(.smooth(duration: 0.12), value: xOffset)
                    .animation(.smooth(duration: 0.12), value: yOffset)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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
