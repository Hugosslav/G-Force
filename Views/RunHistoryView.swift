import SwiftUI

struct RunHistoryView: View {
    @EnvironmentObject private var runRecorder: RunRecorder

    var body: some View {
        NavigationStack {
            List(runRecorder.runs) { run in
                NavigationLink {
                    RunDetailView(run: run)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(run.name)
                            .font(.headline)

                        Text(run.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Peak: \(run.peakTotalG.formatted(.number.precision(.fractionLength(2)))) G")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Runs")
            .overlay {
                if runRecorder.runs.isEmpty {
                    ContentUnavailableView(
                        "No Runs Yet",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Record a run from the Live tab.")
                    )
                }
            }
        }
    }
}