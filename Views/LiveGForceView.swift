import SwiftUI

struct LiveGForceView: View {
    @EnvironmentObject private var motionManager: MotionManager
    @EnvironmentObject private var runRecorder: RunRecorder

    var body: some View {
        VStack(spacing: 32) {
            Text("G-Force")
                .font(.largeTitle)
                .fontWeight(.bold)

            GForceMeterView(
                lateralG: motionManager.lateralG,
                longitudinalG: motionManager.longitudinalG
            )

            VStack(spacing: 8) {
                Text("Total G")
                    .font(.headline)

                Text(motionManager.totalG.formatted(.number.precision(.fractionLength(2))))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }

            Button {
                if runRecorder.isRecording {
                    runRecorder.stopRecording()
                } else {
                    runRecorder.startRecording()
                }
            } label: {
                Text(runRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(runRecorder.isRecording ? Color.red : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            motionManager.start()
        }
        .onReceive(motionManager.$xG) { _ in
            runRecorder.addSample(motionManager.currentSample)
        }
    }
}