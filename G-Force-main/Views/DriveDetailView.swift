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
            VStack(alignment: .leading, spacing: 24) {
                header
                kpiGrid
                chart
                RoutePickerSection(selectedRouteID: $selectedRouteID) { newRouteID in
                    driveStore.assignRoute(newRouteID, toDriveID: drive.id)
                }
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(drive.startDate.formatted(date: .abbreviated, time: .standard))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(Formatters.duration(drive.duration))
                .foregroundStyle(.secondary)
        }
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            kpiCard("Peak G", Formatters.gForce(drive.peakG))
            kpiCard("RMS G", Formatters.gForce(drive.rmsG))
            kpiCard("Score", Formatters.score(drive.score))
            kpiCard("Distance", Formatters.distance(drive.distanceMeters))
            kpiCard("Avg Speed", Formatters.speed(drive.avgSpeedMPS))
        }
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

            Chart(drive.samples) { sample in
                LineMark(
                    x: .value("Time", sample.timestamp),
                    y: .value("G", sample.horizontalG)
                )
            }
            .frame(height: 220)
        }
    }
}
