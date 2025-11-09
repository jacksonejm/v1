import SwiftUI

struct JobDetailView: View {
    @Environment(\.dismiss) var dismiss
    let job: Job

    var body: some View {
        NavigationView {
            VStack {
                Text("Details about \(job.title)")
                    .font(.largeTitle)
                    .padding()

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left side (X button)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                
                // Right side (3 dots button)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for 3 dots button goes here
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper behavior on iPad
    }
}