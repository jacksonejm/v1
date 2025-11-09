import SwiftUI

struct InterestCircle: View {
    let letter: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Text(letter)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)
        }
    }
}