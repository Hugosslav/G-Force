import Charts
import SwiftUI

/// Shown both immediately after a drive ends, and when tapping into a past
/// drive from the Home list — same screen either way, presented as a
/// standard iOS sheet (margin at the top only, rounded top corners).
struct DriveDetailView: View {
    @EnvironmentObject private var driveStore: DriveStore
    @Environment(\.dismiss) private var dismiss

    let drive: Drive
    @State private var selectedRouteID: UUID?

    init(drive: Drive) {
        self.drive = drive
        _selectedRouteID = State(initialValue: drive.routeID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RouteBanner(selectedRouteID: $selectedRouteID) { newRouteID in
                    driveStore.assignRoute(newRouteID, toDriveID: drive.id)
                }

                Text(Formatters.shortTime(drive.startDate))
                    .font(.title3)
                    .foregroundStyle(.secondary)

                kpiGrid
                chart
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            BottomActionButton(
                title: "Close",
                color: BottomActionButton.closeColor
            ) {
                dismiss()
            }
        }
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            scoreCard
            kpiCard("RMS G", Formatters.gForce(drive.rmsG))
            kpiCard("Peak G", Formatters.gForce(drive.peakG))
            kpiCard("Duration", Formatters.durationMinutes(drive.duration))
            kpiCard("Avg Speed", Formatters.speed(drive.avgSpeedMPS))
            kpiCard("Distance", Formatters.distance(drive.distanceMeters))
        }
    }

    private var scoreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Formatters.score(drive.score))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Spacer()
            SkillLevelIcon(score: drive.score, size: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func kpiCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("G-Force Over Time")
                .font(.headline)

            let maxMinutes = max(drive.duration / 60, 1)

            Chart(drive.samples) { sample in
                LineMark(
                    x: .value("Minutes", sample.timestamp.timeIntervalSince(drive.startDate) / 60),
                    y: .value("G", sample.horizontalG)
                )
            }
            .chartXScale(domain: 0...maxMinutes)
            .chartYScale(domain: 0...2)
            .chartXAxisLabel("Minutes")
            .chartYAxisLabel("G")
            .frame(height: 220)
        }
    }
}
