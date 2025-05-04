import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo
            Image("") // Replace "AppLogo" with the name of your logo asset
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120) // Adjust size as needed
                .padding(.bottom, 20)
                .accessibilityLabel("MyPath Logo")
                .accessibilityHint("Logo of the MyPath application")

            // Title
            Text("Welcome to MyPath")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("Welcome to MyPath")
                .accessibilityHint("Main title of the app")

            // Subtitle
            Text("Let's find the career path that best suits your interests.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .accessibilityLabel("Introduction text")
                .accessibilityHint("Guides the user to start finding their career path.")

            // Get Started Button
            Button(action: {
                // Make sure this action triggers the onboarding flow
                withAnimation {
                    viewModel.appFlowState = .onboarding(step: .howDidYouHearAboutUs)
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal)
            .buttonStyle(ScaleButtonStyle()) // Adds hover animation
            .accessibilityLabel("Get Started")
            .accessibilityHint("Tap to start onboarding.")

            // Navigation to Login
            Button(action: {
                // Trigger login flow directly in the view model
                withAnimation {
                    viewModel.appFlowState = .login
                }
            }) {
                Text("Already have an account? Log in")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .underline()
            }
            .accessibilityLabel("Log in")
            .accessibilityHint("Tap to log in to your account.")

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .edgesIgnoringSafeArea(.all)
    }
}

// Button Style for Tactile Feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}