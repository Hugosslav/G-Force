import SwiftUI

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

            let xOffset = (clampedX / maxG) * (radius - dotSize)
            let yOffset = -(clampedY / maxG) * (radius - dotSize)

            ZStack {
                Circle()
                    .stroke(.secondary, lineWidth: 2)

                Circle()
                    .stroke(.secondary.opacity(0.4), lineWidth: 1)
                    .scaleEffect(0.66)

                Circle()
                    .stroke(.secondary.opacity(0.4), lineWidth: 1)
                    .scaleEffect(0.33)

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(width: 1)

                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(height: 1)

                Circle()
                    .fill(.primary)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: xOffset, y: yOffset)
                    .animation(.smooth(duration: 0.12), value: lateralG)
                    .animation(.smooth(duration: 0.12), value: longitudinal