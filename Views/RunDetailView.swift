import SwiftUI
import Charts

struct RunDetailView: View {
    let run: RecordedRun

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(run.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(run.startDate.formatted(date: .abbreviated, time: .standard))
                        .foregroundStyle(.secondary)

                    Text("Peak G: \(run.peakTotalG.formatted(.number.precision(.fractionLength(2))))")
                        .font(.headline)
                }

                Chart(run.samples) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Total G", sample.totalG)
                    )
                }
                .frame(height: 300)
            }
            .padding()
        }
        .navigationTitle("Run Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}