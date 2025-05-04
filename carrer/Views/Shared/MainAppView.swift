import SwiftUI

struct MainAppView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab
            dashboardView
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .tag(0)
            
            // Explore tab
            exploreView
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Explore")
                    }
                }
                .tag(1)
            
            // AI Coach tab
            aiCoachView
                .tabItem {
                    VStack {
                        Image(systemName: "bubble.left.fill")
                        Text("AI Coach")
                    }
                }
                .tag(2)
            
            // Profile tab
            profileView
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
    }
    
    // MARK: - Tab Views
    
    private var dashboardView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Career tracks section
                    careerTracksSection
                    
                    // Recommended careers section
                    recommendedCareersSection
                    
                    // Learning resources section
                    learningResourcesSection
                }
                .padding()
            }
            .navigationTitle("My Career Path")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var exploreView: some View {
        NavigationStack {
            Text("Explore careers, skills, and learning paths")
                .font(.title)
                .padding()
                .navigationTitle("Explore")
        }
    }
    
    private var aiCoachView: some View {
        NavigationStack {
            VStack {
                Text("Talk to your AI career coach")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    // Show AI assistant
                }) {
                    Label("Start conversation", systemImage: "bubble.left.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("AI Coach")
        }
    }
    
    private var profileView: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Profile")) {
                    Text("Account & settings")
                    Text("Your responses")
                    Text("Saved careers")
                }
                
                Section(header: Text("App")) {
                    Text("About MyPath")
                    Text("Help & support")
                    Text("Privacy policy")
                    
                    Button(action: {
                        // Sign out logic
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    // MARK: - Dashboard Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Hello, \(userName)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your career journey continues")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Profile image
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primary)
            }
            
            // Progress card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Career Readiness")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("65%")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(AppColors.primary)
                            .frame(width: geometry.size.width * 0.65, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("Complete more activities to increase your score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var careerTracksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Career Tracks")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.careerTracks) { track in
                        careerTrackCard(track)
                    }
                    
                    if viewModel.careerTracks.isEmpty {
                        // Empty state
                        careerTrackEmptyCard()
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func careerTrackCard(_ track: CareerTrack) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Progress: \(track.progress)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(AppColors.primary)
                        .frame(width: geometry.size.width * CGFloat(track.progress) / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack(spacing: 12) {
                // Salary
                VStack(alignment: .leading, spacing: 2) {
                    Text("Salary")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(track.salary)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Education
                VStack(alignment: .leading, spacing: 2) {
                    Text("Education")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(track.education)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Match
                VStack(alignment: .leading, spacing: 2) {
                    Text("Match")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(track.match)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: 240)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func careerTrackEmptyCard() -> some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.system(size: 36))
                .foregroundColor(AppColors.primary)
            
            Text("Add Career Track")
                .font(.headline)
                .foregroundColor(AppColors.primary)
            
            Text("Start tracking a career path")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 200, height: 160)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var recommendedCareersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended For You")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            // Recommended careers list
            VStack(spacing: 12) {
                ForEach(1...3, id: \.self) { index in
                    recommendedCareerRow(
                        title: ["Software Engineer", "UX Designer", "Data Scientist"][index - 1],
                        match: [95, 87, 82][index - 1]
                    )
                }
            }
        }
    }
    
    private func recommendedCareerRow(title: String, match: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text("Based on your interests and skills")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(match)%")
                .font(.headline)
                .foregroundColor(AppColors.primary)
                .padding(8)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var learningResourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Learning Resources")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    resourceCard(
                        title: "Programming Fundamentals",
                        type: "Course",
                        duration: "6 weeks"
                    )
                    
                    resourceCard(
                        title: "Introduction to UX Design",
                        type: "Workshop",
                        duration: "3 hours"
                    )
                    
                    resourceCard(
                        title: "Data Analysis with Python",
                        type: "Course",
                        duration: "8 weeks"
                    )
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func resourceCard(title: String, type: String, duration: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.primary.opacity(0.8))
                .padding(.bottom, 4)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text(type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 200, height: 160)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Properties
    
    private var userName: String {
        if let name = viewModel.userData[.name] as? String, !name.isEmpty {
            return name
        }
        return "Explorer"
    }
}