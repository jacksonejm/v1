import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var animationAmount = 1.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                Spacer(minLength: 40)

                heroCard

                featureHighlights
                    .modernCard()

                Spacer()

                ctaButtons
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
        }
        .onAppear {
            withAnimation {
                animationAmount = 1.18
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            HStack(spacing: Spacing.large) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 96, height: 96)

                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animationAmount)
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Welcome to MyPath")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Your AI career coach for discovering strengths and mapping next steps.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: Spacing.medium) {
                heroStat(label: "Career tracks", value: "120+", icon: "briefcase.fill")
                heroStat(label: "Skill lessons", value: "60", icon: "graduationcap.fill")
                heroStat(label: "Success score", value: "92%", icon: "sparkle")
            }
        }
        .padding(.vertical, Spacing.xxxl)
        .padding(.horizontal, Spacing.xxxl)
        .background(
            AppGradient.hero
                .mask(
                    RoundedRectangle(cornerRadius: AppCornerRadius.section, style: .continuous)
                )
        )
    }

    private func heroStat(label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14, weight: .semibold))
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var featureHighlights: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            Text("What you’ll experience")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: Spacing.large) {
                featureRow(icon: "wand.and.stars", title: "Personalized discovery", detail: "Tell us about your interests and we’ll craft a unique match profile.")

                featureRow(icon: "rectangle.3.group.bubble.left", title: "Guided conversations", detail: "Chat with MyPath’s coach whenever you need a boost or quick answer.")

                featureRow(icon: "chart.bar.doc.horizontal.fill", title: "Actionable plans", detail: "Get step-by-step tracks with tasks, resources, and milestones.")
            }
        }
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.surfaceSecondary.opacity(0.85))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var ctaButtons: some View {
        VStack(spacing: Spacing.medium) {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Start Phase 0 onboarding flow
                    viewModel.appFlowState = .onboarding(step: .howDidYouHearAboutUs)
                }
            }) {
                HStack {
                    Text("Begin onboarding")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 18)
                .padding(.horizontal, Spacing.xl)
                .background(AppGradient.hero)
                .cornerRadius(AppCornerRadius.pill)
                .shadow(color: AppShadow.subtle, radius: 16, x: 0, y: 12)
            }
            .buttonStyle(.plain)

            Button(action: {
                viewModel.navigateTo(.login)
            }) {
                HStack {
                    Text("I already have an account")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(AppColors.primary)
                .padding(.vertical, 16)
                .padding(.horizontal, Spacing.xl)
                .background(AppColors.surfaceSecondary.opacity(0.75))
                .cornerRadius(AppCornerRadius.pill)
            }
            .buttonStyle(.plain)
        }
    }
}
