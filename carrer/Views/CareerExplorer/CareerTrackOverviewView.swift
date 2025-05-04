import SwiftUI

struct CareerTrackOverviewView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Career Track Progress")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Action to navigate to Career Track Detail View
                }) {
                    Text("View Details")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            // Progress Bar Example
            ProgressView(value: 0.5) // Example of progress, adjust dynamically
                .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
            
            Text("50% completed towards your goal as a Software Engineer")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}