import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var animationAmount = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App logo
            VStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primary)
                    .scaleEffect(animationAmount)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.4)
                            .repeatForever(autoreverses: true),
                        value: animationAmount
                    )
                    .onAppear {
                        withAnimation {
                            animationAmount = 1.2
                        }
                    }
                
                Text("MyPath")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 20)
            
            // Headline
            Text("Discover Your Career Path")
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description
            Text("MyPath helps you explore careers that match your interests, skills, and personality.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Call-to-action buttons
            VStack(spacing: 16) {
                // Get Started button
                Button(action: {
                    viewModel.navigateTo(.onboardingModeSelection)
                }) {
                    HStack {
                        Spacer()
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
                
                // Login button
                Button(action: {
                    viewModel.navigateTo(.login)
                }) {
                    HStack {
                        Spacer()
                        Text("I Already Have an Account")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                        Spacer()
                    }
                    .padding()
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}