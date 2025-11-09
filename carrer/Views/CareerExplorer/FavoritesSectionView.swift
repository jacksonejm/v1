import SwiftUI
import Foundation
import Combine

struct FavoritesSectionView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            if viewModel.favoriteItems.isEmpty {
                Text("You don't have any favorites yet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.favoriteItems, id: \.self) { item in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            viewModel.removeFromFavorites(item)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
    }
}