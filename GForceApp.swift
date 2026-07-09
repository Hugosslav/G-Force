import SwiftUI

@main
struct GForceApp: App {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var runRecorder = RunRecorder()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionManager)
                .environmentObject(runRecorder)
        }
    }
}