import SwiftUI

/// Pill component displaying qualitative match tier (High/Medium/Low)
/// Replaces numeric percentage display in career cards and headers
struct MatchPill: View {
    let tier: MatchTier
    let size: Size

    enum Size {
        case small   // 12pt text, compact padding
        case medium  // 13pt text, standard padding
        case large   // 14pt text, generous padding
    }

    init(tier: MatchTier, size: Size = .medium) {
        self.tier = tier
        self.size = size
    }

    var body: some View {
        Text(tier.label)
            .font(fontSize)
            .fontWeight(.medium)
            .foregroundColor(tier.foregroundColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(tier.backgroundColor)
            .cornerRadius(999) // Fully rounded pill
            .accessibilityLabel(tier.accessibilityLabel)
    }

    // MARK: - Size-specific styling

    private var fontSize: Font {
        switch size {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .footnote
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 10
        case .large: return 12
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 3
        case .medium: return 4
        case .large: return 6
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MatchPill_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Size variants
            VStack(alignment: .leading, spacing: 12) {
                Text("Small size")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    MatchPill(tier: .high, size: .small)
                    MatchPill(tier: .medium, size: .small)
                    MatchPill(tier: .low, size: .small)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Medium size (default)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    MatchPill(tier: .high)
                    MatchPill(tier: .medium)
                    MatchPill(tier: .low)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Large size")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    MatchPill(tier: .high, size: .large)
                    MatchPill(tier: .medium, size: .large)
                    MatchPill(tier: .low, size: .large)
                }
            }

            Divider()

            // Dark mode preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Dark mode")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    MatchPill(tier: .high)
                    MatchPill(tier: .medium)
                    MatchPill(tier: .low)
                }
            }
            .preferredColorScheme(.dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
