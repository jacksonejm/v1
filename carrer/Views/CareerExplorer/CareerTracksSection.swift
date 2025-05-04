import SwiftUI

struct CareerTracksSection: View {
    let tracks: [CareerTrack]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Career Tracks")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tracks) { track in
                    CareerTrackCard(
                        title: track.title,
                        progress: track.progress
                    )
                }
            }
            
            Button("View all tracks") {
                // Handle view all tracks action
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
}