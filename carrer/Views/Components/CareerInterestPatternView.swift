import SwiftUI

struct CareerInterestPatternView: View {
    let firstInitial: String
    let secondInitial: String
    
    var body: some View {
        HStack(spacing: 10) {
            // First Circle (firstInitial)
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay(
                    Text(firstInitial)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .bold))
                )
            
            // Line between circles
            Rectangle()
                .fill(Color.gray)
                .frame(width: 20, height: 2)
            
            // Second Circle (secondInitial)
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay(
                    Text(secondInitial)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .bold))
                )
            
            Spacer().frame(width: 10)
            
            // Text describing pattern
            Text("is your career interest pattern")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            Spacer() // Push everything to the left
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}