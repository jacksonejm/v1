import SwiftUI

struct SplashScreen: View {
    @Binding var isPresented: Bool
    @State private var scaleEffect: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Logo
                Image("") // Replace with your logo asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatCount(1, autoreverses: false)) {
                            scaleEffect = 1.2
                        }
                    }
                
                // App Name
                Text("Welcome to MyPath")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 20)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0), value: opacity)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate and transition to WelcomeView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                    scaleEffect = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                }
            }
        }
    }
}