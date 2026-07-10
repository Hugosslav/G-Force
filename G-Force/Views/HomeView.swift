import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var driveSession: DriveSession

    @State private var isDriveActive = false
    @State private var detailDrive: Drive?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("G-Force")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                Spacer(minLength: 0)

                driveList
            }
            .safeAreaInset(edge: .bottom) {
                BottomActionButton(
                    title: "Start Drive",
                    color: BottomActionButton.startColor
                ) {
                    isDriveActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isDriveActive) {
            LiveDriveView { finishedDrive in
                driveStore.addDrive(finishedDrive)
                isDriveActive = false
                detailDrive = finishedDrive
            }
            .environmentObject(driveSession)
        }
        .sheet(item: $detailDrive) { drive in
            DriveDetailView(drive: drive)
                .environmentObject(driveStore)
        }
    }

    @ViewBuilder
    private var driveList: some View {
        if driveStore.drives.isEmpty {
            ContentUnavailableView(
                "No Drives Yet",
                systemImage: "gauge.with.dots.needle.67percent",
                description: Text("Tap Start Drive to record your first one.")
            )
            .frame(maxHeight: .infinity)
        } else {
            List(driveStore.drives) { drive in
                Button {
                    detailDrive = drive
                } label: {
                    DriveRow(drive: drive, route: driveStore.route(for: drive))
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
    }
}

private struct DriveRow: View {
    let drive: Drive
    let route: Route?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(route?.name ?? "No Route")
                        .font(.headline)
                        .foregroundStyle(route == nil ? .secondary : .primary)
                    Spacer()
                    Text(Formatters.shortDate(drive.startDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 3), spacing: 4) {
                    statLabel("Score", Formatters.score(drive.score))
                    statLabel("RMS", Formatters.gForce(drive.rmsG))
                    statLabel("Peak", Formatters.gForce(drive.peakG))
                    statLabel("Duration", Formatters.durationMinutes(drive.duration))
                    statLabel("Avg", Formatters.speed(drive.avgSpeedMPS))
                    statLabel("Dist", Formatters.distance(drive.distanceMeters))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            SkillLevelIcon(score: drive.score, size: 26)
        }
        .padding(.vertical, 4)
    }

    private func statLabel(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
            Text(value)
                .foregroundStyle(.primary)
        }
    }
}
