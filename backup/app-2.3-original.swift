import SwiftUI

import Firebase

import FirebaseCore




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





enum UserDataKey: Hashable {
    case howDidYouHearAboutUs
    case personalizeExperience
    case currentStatus
    case interestProfile
    case riasecResponses
    case riasecResults
    case questionBank
    case suggestions
    case careerTracks
    case completedSkills
    case completedActivities
    case selectedDimensions // Add this line
    case currentQuestionPage
}











import SwiftUI
import AuthenticationServices

import SwiftUI

import SwiftUI

struct AccountCreationPromptView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showSignUpView = false

    var body: some View {
        VStack {
            Spacer()
            Text("Create an Account")
                .font(.title)
                .padding()

            Text("Save your preferences and jumpstart your practice.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Button to show the full-screen sheet
            Button(action: {
                showSignUpView = true
            }) {
                Text("Continue with Email")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            // Presenting SignUpView as a full-screen sheet
            .sheet(isPresented: $showSignUpView) {
                SignUpView(viewModel: viewModel) // Pass the viewModel to the SignUpView
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }

            SignInWithAppleButton(
                onRequest: { request in
                    // Configure the request
                },
                onCompletion: { result in
                    // Handle the result
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            .padding(.horizontal)

            Button(action: {
                // Handle sign in
            }) {
                Text("Sign In")
                    .font(.subheadline)
                    .underline()
                    .padding()
            }

            Spacer()
        }
        .padding()
    }
}













struct WelcomeView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Welcome to MyPath")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.primaryBlue)
                .frame(maxWidth: .infinity)

            Text("Let's find the career path that best suits your interests.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)

            Button(action: {
                viewModel.appFlowState = .onboarding(step: .howDidYouHearAboutUs)
            }) {
                Text("Get Started")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            // NavigationLink to LoginView
            NavigationLink(destination: LoginView(viewModel: viewModel)) {
                Text("Already have an account? Log in")
                    .font(.subheadline)
        
                    .foregroundColor(.primaryBlue)
                    .underline()
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}






struct InterestCircle: View {
    let letter: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Text(letter)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)
        }
    }
}

struct CareerTrackSectionView: View {
    let careerTracks: [CareerTrack]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Career Track Progress")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {}) {
                    Text("Add Track")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(careerTracks) { track in
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.title)
                                .font(.headline)
                            Text("\(track.match)% Match with Your Profile")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(track.progress)% Complete")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.1)
                                .foregroundColor(.blue)
                            
                            Rectangle()
                                .frame(width: min(CGFloat(track.progress) * geometry.size.width / 100, geometry.size.width), height: 8)
                                .foregroundColor(.blue)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Salary: \(track.salary)")
                        Spacer()
                        Text("Education: \(track.education)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
    }
}



struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Career Guidance Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            Spacer()
        }
    }
}


// Recommended Next Steps Section
struct RecommendedNextStepsView: View {
    let steps = [
        ("Complete Detailed Assessment", "Get more accurate recommendations"),
        ("Watch Industry Insights", "3 new videos available"),
        ("Explore Required Skills", "Technical & soft skills analysis")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recommended Next Steps")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {}) {
                    Text("View More")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Divider()
            
            ForEach(steps, id: \.0) { step in
                HStack {
                    VStack(alignment: .leading) {
                        Text(step.0)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(step.1)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
                Divider()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


struct NextStepItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

// Learning Resources Section
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




// Circle view for RIASEC initials
struct CircleView: View {
    let initial: String
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                Text(initial)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            )
    }
}


struct CareerInterestPatternView: View {
    let firstInitial: String
    let secondInitial: String
    
    var body: some View {
        HStack(spacing: 10) {
            // First Circle (firstInitial)
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay(
                    Text(firstInitial)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .bold))
                )
            
            // Line between circles
            Rectangle()
                .fill(Color.gray)
                .frame(width: 20, height: 2)
            
            // Second Circle (secondInitial)
            Circle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay(
                    Text(secondInitial)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .bold))
                )
            
            Spacer().frame(width: 10)
            
            // Text describing pattern
            Text("is your career interest pattern")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            Spacer() // Push everything to the left
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}


struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}








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

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let progress: Int
    let status: MilestoneStatus
    let actionTitle: String
}

enum MilestoneStatus {
    case completed
    case inProgress
    case pending
}

struct MilestoneCard: View {
    let milestone: Milestone
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: statusIcon)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title)
                        .font(.headline)
                    
                    Text(milestone.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Progress Label
                Text("\(milestone.progress)%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(milestone.progress) / 100, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            // Action Button
            Button(action: {
                // Handle action
            }) {
                Text(milestone.actionTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(actionButtonColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var statusIcon: String {
        switch milestone.status {
        case .completed:
            return "checkmark.circle.fill"
        case .inProgress:
            return "clock.fill"
        case .pending:
            return "circle"
        }
    }
    
    private var backgroundColor: Color {
        switch milestone.status {
        case .completed:
            return Color.green.opacity(0.1)
        case .inProgress:
            return Color.blue.opacity(0.1)
        case .pending:
            return Color.gray.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
    
    private var progressColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
    
    private var actionButtonColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
}















struct TimelineView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}

struct TimelineItem: View {
    let date: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}



struct HeaderSection: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello, \(viewModel.userData[.personalizeExperience] as? String ?? "Guest")!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Let's continue your journey")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}




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









// Placeholder Views for Navigation Destinations
struct CareerTracksView: View {
    var body: some View {
        Text("Career Tracks View")
            .navigationTitle("Career Tracks")
    }
}

struct LearningPathView: View {
    var body: some View {
        Text("Learning Path View")
            .navigationTitle("Learning Path")
    }
}

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


struct JobCarousel: View {
    let jobs: [Job]
    @Binding var selectedJob: Job? // Binding to set the selected job when tapped

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(jobs) { job in
                    JobCard(job: job)
                        .onTapGesture {
                            selectedJob = job
                        }
                }
            }
        }
        .frame(height: 150)
    }
}

struct JobCard: View {
    let job: Job

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        VStack {
            Text(job.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(width: screenWidth * 0.8, height: 150)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Use NavigationView for JobDetailView and make it fullscreen
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



import SwiftUI

struct OnboardingTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.textBlack)
            .padding(.top, 10)
    }
}

struct OnboardingSecondaryTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .foregroundColor(.textBlack)
            .padding(.top, 20)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}





import Foundation

enum RIASECQuestion: CaseIterable, Hashable {
    case realistic(String, ScaleType)
    case investigative(String, ScaleType)
    case artistic(String, ScaleType)
    case social(String, ScaleType)
    case enterprising(String, ScaleType)
    case conventional(String, ScaleType)

    enum ScaleType {
        case agreement
        case frequency
    }

    var text: String {
        switch self {
        case .realistic(let question, _),
             .investigative(let question, _),
             .artistic(let question, _),
             .social(let question, _),
             .enterprising(let question, _),
             .conventional(let question, _):
            return question
        }
    }

    var category: String {
        switch self {
        case .realistic:
            return "Realistic"
        case .investigative:
            return "Investigative"
        case .artistic:
            return "Artistic"
        case .social:
            return "Social"
        case .enterprising:
            return "Enterprising"
        case .conventional:
            return "Conventional"
        }
    }

    var scaleType: ScaleType {
        switch self {
        case .realistic(_, let scale),
             .investigative(_, let scale),
             .artistic(_, let scale),
             .social(_, let scale),
             .enterprising(_, let scale),
             .conventional(_, let scale):
            return scale
        }
    }

    static var allCases: [RIASECQuestion] {
        return [
            // Realistic
            .realistic("Do you enjoy working with your hands?", .agreement),
            .realistic("Do you like repairing things?", .agreement),
            .realistic("How often do you participate in physical activities?", .frequency),
            // Investigative
            .investigative("Do you enjoy solving puzzles?", .agreement),
            .investigative("Do you like conducting experiments?", .agreement),
            .investigative("How often do you read science articles?", .frequency),
            // Artistic
            .artistic("Do you enjoy creative activities like drawing or painting?", .agreement),
            .artistic("Do you like writing stories or poetry?", .agreement),
            .artistic("How often do you participate in artistic events?", .frequency),
            // Social
            .social("Do you enjoy helping others?", .agreement),
            .social("Do you like teaching or instructing people?", .agreement),
            .social("How often do you volunteer in community services?", .frequency),
            // Enterprising
            .enterprising("Do you enjoy leading groups?", .agreement),
            .enterprising("Do you like persuading others?", .agreement),
            .enterprising("How often do you participate in leadership roles?", .frequency),
            // Conventional
            .conventional("Do you enjoy organizing things?", .agreement),
            .conventional("Do you like working with data or numbers?", .agreement),
            .conventional("How often do you create plans or schedules?", .frequency)
        ]
    }
}

class RIASECScoreCalculator {
    static func calculate(from responses: [RIASECQuestion: Int]) -> [String: Int] {
        return responses.reduce(into: [:]) { scores, response in
            let ratingValue = response.value
            scores[response.key.category, default: 0] += ratingValue
        }
    }
}




struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}





// SignUpView.swift

import SwiftUI
import FirebaseAuth






// MARK: - Collection Extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

