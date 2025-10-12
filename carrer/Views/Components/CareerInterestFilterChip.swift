import SwiftUI

/// A toggleable chip component for filtering career interests
/// Used in AllRecommendationsView to show/hide career interest boosts
struct CareerInterestFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Checkmark icon
                Image(systemName: isSelected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .gray)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppColors.primary : Color.gray.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
#if DEBUG
struct CareerInterestFilterChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            CareerInterestFilterChip(
                title: "Engineer",
                isSelected: true,
                action: {}
            )

            CareerInterestFilterChip(
                title: "Research Scientist",
                isSelected: false,
                action: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
