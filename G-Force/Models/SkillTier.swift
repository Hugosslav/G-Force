import SwiftUI

/// Maps a score to a visual "skill tier". Score is g-force-based and lower is
/// better (see Drive.score) — so the thresholds here are upper bounds, and the
/// first one you're still under wins.
///
/// The thresholds are a first guess, not a calibrated model — there's no real
/// drive data yet to know what "smooth" actually looks like numerically for
/// you two specifically. Expect to retune these once you've logged some drives.
enum SkillTier: CaseIterable {
    case legend
    case pro
    case medium
    case bad

    /// Score must be <= this value to qualify for the tier (checked in
    /// declaration order, so `legend`'s bound is the tightest).
    private var scoreUpperBound: Double {
        switch self {
        case .legend: return 0.15
        case .pro: return 0.25
        case .medium: return 0.40
        case .bad: return .infinity
        }
    }

    static func forScore(_ score: Double) -> SkillTier {
        for tier in SkillTier.allCases where score <= tier.scoreUpperBound {
            return tier
        }
        return .bad
    }

    /// SF Symbols has no Formula 1 / Porsche-specific icons, and recreating a
    /// brand silhouette would be a trademark issue anyway — using a generic
    /// car icon differentiated by tint for the top three tiers instead.
    var iconName: String {
        switch self {
        case .legend, .pro, .medium: return "car.fill"
        case .bad: return "trash.fill"
        }
    }

    var tint: Color {
        switch self {
        case .legend: return Color(red: 1.0, green: 0.84, blue: 0.0) // gold
        case .pro: return .red
        case .medium: return .gray
        case .bad: return .gray
        }
    }

    var label: String {
        switch self {
        case .legend: return "Legend"
        case .pro: return "Pro"
        case .medium: return "Medium"
        case .bad: return "Bad"
        }
    }
}
