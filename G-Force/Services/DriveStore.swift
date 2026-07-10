import Foundation
import Combine

/// Persists drives and routes to JSON files in the app's Documents directory.
/// Deliberately simple (no Core Data/SwiftData) for a first version — the
/// models are already Codable, so swapping this out later is cheap if needed.
final class DriveStore: ObservableObject {
    @Published private(set) var drives: [Drive] = []
    @Published private(set) var routes: [Route] = []

    private let drivesURL: URL
    private let routesURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        drivesURL = documents.appendingPathComponent("drives.json")
        routesURL = documents.appendingPathComponent("routes.json")
        load()
    }

    func addDrive(_ drive: Drive) {
        drives.insert(drive, at: 0)
        saveDrives()
    }

    func addRoute(name: String, colorHex: String) -> Route {
        let route = Route(name: name, colorHex: colorHex)
        routes.append(route)
        saveRoutes()
        return route
    }

    func assignRoute(_ routeID: UUID?, toDriveID driveID: UUID) {
        guard let index = drives.firstIndex(where: { $0.id == driveID }) else { return }
        drives[index].routeID = routeID
        saveDrives()
    }

    func route(for drive: Drive) -> Route? {
        guard let routeID = drive.routeID else { return nil }
        return routes.first { $0.id == routeID }
    }

    private func load() {
        if let data = try? Data(contentsOf: drivesURL),
           let decoded = try? JSONDecoder().decode([Drive].self, from: data) {
            drives = decoded
        }
        if let data = try? Data(contentsOf: routesURL),
           let decoded = try? JSONDecoder().decode([Route].self, from: data) {
            routes = decoded
        }
    }

    private func saveDrives() {
        guard let data = try? JSONEncoder().encode(drives) else { return }
        try? data.write(to: drivesURL, options: .atomic)
    }

    private func saveRoutes() {
        guard let data = try? JSONEncoder().encode(routes) else { return }
        try? data.write(to: routesURL, options: .atomic)
    }
}
