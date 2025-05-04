import SwiftUI

struct TypingIndicator: View {
    @State private var firstDotOpacity: Double = 0.4
    @State private var secondDotOpacity: Double = 0.4
    @State private var thirdDotOpacity: Double = 0.4
    
    var body: some View {
        HStack(spacing: 4) {
            Text("AI:")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.trailing, 4)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(firstDotOpacity)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(secondDotOpacity)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(thirdDotOpacity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(18)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let animation = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        
        withAnimation(animation) {
            firstDotOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(animation) {
                secondDotOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(animation) {
                thirdDotOpacity = 1.0
            }
        }
    }
}