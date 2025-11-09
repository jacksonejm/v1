import SwiftUI

/// Country selection view for onboarding
/// Determines whether user receives O*NET (US) or OaSIS/NOC (Canadian) data
struct CountrySelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCountry: UserCountry = .usa

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("Where are you located?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("We'll personalize career recommendations for your region")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 40)

                // Country Options
                VStack(spacing: 16) {
                    ForEach(UserCountry.allCases) { country in
                        CountryOptionCard(
                            country: country,
                            isSelected: selectedCountry == country,
                            action: { selectedCountry = country }
                        )
                    }
                }
                .padding(.horizontal, 24)

                // Info Box
                InfoBox()
                    .padding(.horizontal, 24)

                Spacer()

                // Continue Button
                Button(action: {
                    viewModel.userCountry = selectedCountry
                    viewModel.nextOnboardingStep()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Country")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-select user's current country if already set
            selectedCountry = viewModel.userCountry
        }
    }
}

// MARK: - Country Option Card

struct CountryOptionCard: View {
    let country: UserCountry
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag
                Text(country.flag)
                    .font(.system(size: 48))

                // Country Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(country.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Career data: \(country.usesNOC ? "OaSIS/NOC" : "O*NET")")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if country.supportsBilingual {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.caption2)
                            Text("Bilingual (EN/FR)")
                                .font(.caption2)
                        }
                        .foregroundColor(AppColors.primary)
                    }
                }

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primary.opacity(0.05) : Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Box

struct InfoBox: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppColors.primary)

                    Text("Why does this matter?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your country selection determines:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    InfoRow(icon: "briefcase", text: "Career data source (O*NET or OaSIS/NOC)")
                    InfoRow(icon: "doc.text", text: "Job titles and descriptions")
                    InfoRow(icon: "graduationcap", text: "Education and licensing requirements")
                    InfoRow(icon: "dollarsign.circle", text: "Salary ranges and job outlook")

                    Text("Both use the same proven career matching algorithm (RIASEC).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppColors.primary)
                .frame(width: 20)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CountrySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountrySelectionView(viewModel: AppViewModel())
        }
    }
}
#endif
