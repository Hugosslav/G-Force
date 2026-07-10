import SwiftUI

@main
struct GForceApp: App {
    @StateObject private var driveStore = DriveStore()
    @StateObject private var locationService: LocationService
    @StateObject private var driveSession: DriveSession

    init() {
        let location = LocationService()
        let motion = MotionManager()
        _locationService = StateObject(wrappedValue: location)
        _driveSession = StateObject(wrappedValue: DriveSession(
            motionManager: motion,
            locationService: location
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(driveStore)
                .environmentObject(driveSession)
                .onAppear {
                    locationService.requestAuthorization()
                }
        }
    }
}
