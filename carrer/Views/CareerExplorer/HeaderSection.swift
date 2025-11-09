import SwiftUI

// Add import for UserDataKey
import Foundation

struct HeaderSection: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello, \(viewModel.userData[.personalizeExperience] as? String ?? "Guest")!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Let's continue your journey")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}