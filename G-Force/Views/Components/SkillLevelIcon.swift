import SwiftUI

/// Shared skill-tier icon — used large & translucent on the Live screen,
/// small & solid in KPI cards and Home rows. Always derived from a live
/// score value so it updates immediately as score changes.
struct SkillLevelIcon: View {
    let score: Double
    var size: CGFloat = 28
    var opacity: Double = 1.0

    private var tier: SkillTier {
        SkillTier.forScore(score)
    }

    var body: some View {
        Image(systemName: tier.iconName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(tier.tint)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.3), value: tier)
    }
}

// Note: SkillTier already gets automatic Equatable/Hashable synthesis since
// it's a plain enum with no associated values — no explicit conformance needed.

#Preview {
    VStack(spacing: 20) {
        SkillLevelIcon(score: 0.10, size: 80, opacity: 0.5)
        SkillLevelIcon(score: 0.20)
        SkillLevelIcon(score: 0.35)
        SkillLevelIcon(score: 0.60)
    }
}
