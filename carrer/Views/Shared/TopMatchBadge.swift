import SwiftUI

/// Badge component showing "⭐ Top match" for the top 3 career recommendations
/// Displays before the MatchPill to highlight the best matches
struct TopMatchBadge: View {
    let size: Size

    enum Size {
        case small   // 12pt text, compact padding
        case medium  // 13pt text, standard padding
        case large   // 14pt text, generous padding
    }

    init(size: Size = .medium) {
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(iconFont)

            Text("Top match")
                .font(textFont)
                .fontWeight(.semibold)
        }
        .foregroundColor(.orange)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(999) // Fully rounded pill
        .accessibilityLabel("Top match")
    }

    // MARK: - Size-specific styling

    private var textFont: Font {
        switch size {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .footnote
        }
    }

    private var iconFont: Font {
        switch size {
        case .small: return .system(size: 11)
        case .medium: return .system(size: 12)
        case .large: return .system(size: 13)
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
struct TopMatchBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Size variants
            VStack(alignment: .leading, spacing: 12) {
                Text("Small size")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TopMatchBadge(size: .small)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Medium size (default)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TopMatchBadge()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Large size")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TopMatchBadge(size: .large)
            }

            Divider()

            // Combined with MatchPill
            VStack(alignment: .leading, spacing: 12) {
                Text("With match pill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    TopMatchBadge()
                    MatchPill(tier: .high)
                }
            }

            Divider()

            // Dark mode preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Dark mode")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    TopMatchBadge()
                    MatchPill(tier: .high)
                }
            }
            .preferredColorScheme(.dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
