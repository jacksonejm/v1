import SwiftUI

struct ResourcesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources for Your Career Track")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ResourceCard(
                    title: "Morning Glory",
                    duration: "15 min",
                    description: "Project Management Essentials",
                    author: "Justin Michael"
                )
                
                ResourceCard(
                    title: "Start Your Day Positively",
                    duration: "37 sec",
                    description: "Effective Communication in HR",
                    author: "Don Joseph"
                )
                
                ResourceCard(
                    title: "5 Minute Overview of Python",
                    duration: "6 min",
                    description: "Quick tutorial on Python for Data Science",
                    author: "Fatima"
                )
            }
            
            Button("View all resources") {
                // Handle view all resources action
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