import SwiftUI

struct CareerReadinessView: View {
    @Environment(\.dismiss) var dismiss
    
    let milestones = [
        Milestone(
            title: "RIASEC Assessment",
            description: "Understanding your career interests",
            progress: 100,
            status: .completed,
            actionTitle: "View Results"
        ),
        Milestone(
            title: "Personal Information",
            description: "Your basic profile details",
            progress: 100,
            status: .completed,
            actionTitle: "Edit"
        ),
        Milestone(
            title: "Career Interests",
            description: "Industries and roles you're interested in",
            progress: 100,
            status: .completed,
            actionTitle: "Edit"
        ),
        Milestone(
            title: "Education Background",
            description: "Your academic qualifications",
            progress: 100,
            status: .completed,
            actionTitle: "Edit"
        ),
        Milestone(
            title: "Skills Assessment",
            description: "Technical and soft skills evaluation",
            progress: 80,
            status: .inProgress,
            actionTitle: "Continue Assessment"
        ),
        Milestone(
            title: "Resume/Portfolio",
            description: "Showcase your experience and work",
            progress: 0,
            status: .pending,
            actionTitle: "Get Started"
        ),
        Milestone(
            title: "Professional Goals",
            description: "Define your career objectives",
            progress: 0,
            status: .pending,
            actionTitle: "Set Goals"
        ),
        Milestone(
            title: "Industry Preferences",
            description: "Target industries and companies",
            progress: 0,
            status: .pending,
            actionTitle: "Add Preferences"
        )
    ]
    
    var overallProgress: Int {
        Int(Double(milestones.map { $0.progress }.reduce(0, +)) / Double(milestones.count))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with Progress
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(overallProgress) / 100)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(overallProgress)%")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Complete")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Career Readiness")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Complete all milestones to maximize your career opportunities")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Milestones List
                VStack(spacing: 16) {
                    ForEach(milestones) { milestone in
                        MilestoneCard(milestone: milestone)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
        }
    }
}