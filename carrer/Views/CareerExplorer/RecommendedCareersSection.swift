import SwiftUI

// Add missing model imports
import Foundation

struct RecommendedCareersSection: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended Careers")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    JobMatchCard(
                        job: Job(
                            title: "Data Scientist",
                            focus: "AI and Machine Learning focus",
                            salaryRange: "$90K - $150K",
                            growth: "High Growth",
                            matchPercentage: 95
                        )
                    )
                    
                    JobMatchCard(
                        job: Job(
                            title: "HR Manager",
                            focus: "Employee Relations specialist",
                            salaryRange: "$75K - $120K",
                            growth: "Moderate Growth",
                            matchPercentage: 88
                        )
                    )
                    
                    JobMatchCard(
                        job: Job(
                            title: "Business Analyst",
                            focus: "Data-driven decision making",
                            salaryRange: "$70K - $110K",
                            growth: "High Growth",
                            matchPercentage: 82
                        )
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
}