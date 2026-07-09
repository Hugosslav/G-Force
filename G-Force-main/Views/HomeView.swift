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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(drive.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Spacer()
                routeBadge
            }

            Text(Formatters.duration(drive.duration))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                statLabel("Peak", Formatters.gForce(drive.peakG))
                statLabel("RMS", Formatters.gForce(drive.rmsG))
                statLabel("Score", Formatters.score(drive.score))
                statLabel("Dist", Formatters.distance(drive.distanceMeters))
                statLabel("Avg", Formatters.speed(drive.avgSpeedMPS))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var routeBadge: some View {
        if let route {
            Label(route.name, systemImage: "circle.fill")
                .labelStyle(.titleAndIcon)
                .font(.caption)
                .foregroundStyle(route.color)
        } else {
            Text("No route")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func statLabel(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
            Text(value)
                .foregroundStyle(.primary)
        }
    }
}
