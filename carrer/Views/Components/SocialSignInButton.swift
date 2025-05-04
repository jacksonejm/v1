import SwiftUI
import UIKit

struct SocialSignInButton: View {
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: IconSize.large, height: IconSize.large)
        }
        .padding(Spacing.xs)
    }
}