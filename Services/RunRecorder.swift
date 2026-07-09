import Foundation

final class RunRecorder: ObservableObject {
    @Published private(set) var runs: [RecordedRun] = []
    @Published private(set) var currentSamples: [GSample] = []
    @Published private(set) var isRecording = false

    private var recordingStartDate: Date?

    func startRecording() {
        currentSamples = []
        recordingStartDate = Date()
        isRecording = true
    }

    func addSample(_ sample: GSample) {
        guard isRecording else { return }
        currentSamples.append(sample)
    }

    func stopRecording() {
        guard let startDate = recordingStartDate else { return }

        let run = RecordedRun(
            id: UUID(),
            name: "Run \(runs.count + 1)",
            startDate: startDate,
            endDate: Date(),
            samples: currentSamples
        )

        runs.insert(run, at: 0)
        currentSamples = []
        recordingStartDate = nil
        isRecording = false
    }
}