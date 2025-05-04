import SwiftUI

struct CareerLearningSection: View {
    var body: some View {
        // Career & Learning Path Cards
        HStack(spacing: 12) {
            // Career Tracks Card
            NavigationLink(destination: CareerTracksView()) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "medal.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Career Tracks")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Learning Path Card
            NavigationLink(destination: LearningPathView()) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Learning Path")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
    }
}