import Foundation

/// A completed, recorded drive. Replaces the old `RecordedRun` — renamed for
/// consistency with the rest of the app's terminology.
struct Drive: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let startDate: Date
    let endDate: Date
    let samples: [GSample]

    /// Total distance covered, in meters. Nil if location wasn't available for the drive.
    var distanceMeters: Double?
    /// Average speed across the whole drive, in meters/second.
    var avgSpeedMPS: Double?

    /// Assigned after the drive ends, via the Detail screen. Nil = untagged.
    var routeID: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        samples: [GSample],
        distanceMeters: Double? = nil,
        avgSpeedMPS: Double? = nil,
        routeID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.samples = samples
        self.distanceMeters = distanceMeters
        self.avgSpeedMPS = avgSpeedMPS
        self.routeID = routeID
    }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    /// Peak horizontal g-force reached during the drive.
    var peakG: Double {
        samples.map(\.horizontalG).max() ?? 0
    }

    /// RMS (root-mean-square) horizontal g-force across the drive — the baseline
    /// smoothness measure. See GSample.horizontalG for why vertical g is excluded.
    var rmsG: Double {
        guard !samples.isEmpty else { return 0 }
        let sumOfSquares = samples.reduce(0) { $0 + $1.horizontalG * $1.horizontalG }
        return (sumOfSquares / Double(samples.count)).squareRoot()
    }

    /// Comfort score placeholder. The real model (RMS as a baseline, weighted extra
    /// for high-g spikes — see conversation notes) hasn't been built yet.
    /// Returns nil deliberately; UI should render this as "—", not a fake number.
    var score: Double? {
        nil
    }
}
