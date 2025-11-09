import SwiftUI

struct CircleView: View {
    let initial: String
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                Text(initial)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            )
    }
}