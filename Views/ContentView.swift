import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LiveGForceView()
                .tabItem {
                    Label("Live", systemImage: "gauge")
                }

            RunHistoryView()
                .tabItem {
                    Label("Runs", systemImage: "chart.xyaxis.line")
                }
        }
    }
}