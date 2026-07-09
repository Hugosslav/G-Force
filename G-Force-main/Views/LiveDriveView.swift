import SwiftUI

struct LiveDriveView: View {
    @EnvironmentObject private var driveSession: DriveSession

    /// Called once the drive has been stopped and a Drive record produced.
    let onStop: (Drive) -> Void

    var body: some View {
        VStack(spacing: 24) {
            kpiBar

            GForceMeterView(
                lateralG: driveSession.smoothedLateralG,
                longitudinalG: driveSession.smoothedLongitudinalG
            )
            .padding(.horizontal, 24)
            .aspectRatio(1, contentMode: .fit)

            VStack(spacing: 4) {
                Text("Current G")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(Formatters.gForce(driveSession.currentHorizontalG))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }

            Spacer(minLength: 0)
        }
        .padding(.top)
        .safeAreaInset(edge: .bottom) {
            BottomActionButton(
                title: "Stop Drive",
                color: BottomActionButton.stopColor
            ) {
                if let drive = driveSession.stop() {
                    onStop(drive)
                }
            }
        }
        .onAppear {
            driveSession.start()
        }
        .interactiveDismissDisabled()
    }

    private var kpiBar: some View {
        HStack {
            kpiItem("Peak G", Formatters.gForce(driveSession.livePeakG))
            Spacer()
            kpiItem("RMS G", Formatters.gForce(driveSession.liveRMSG))
            Spacer()
            kpiItem("Score", Formatters.score(nil))
        }
        .padding(.horizontal, 24)
    }

    private func kpiItem(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
