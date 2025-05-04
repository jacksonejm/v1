import SwiftUI

struct LearningResourcesView: View {
    let resources: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Top Resources")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {}) {
                    Text("Explore More")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Divider()
            
            ForEach(resources, id: \.self) { resource in
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.blue)
                    Text(resource)
                        .font(.subheadline)
                    Spacer()
                }
                Divider()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}