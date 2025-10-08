import SwiftUI

struct MainAppView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    @State private var showMatchPercentageInfo = false

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
            .sheet(isPresented: $showMatchPercentageInfo) {
                matchPercentageInfoSheet
            }
        }
    }

    private var matchPercentageInfoSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Understanding Your Match %")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Your match percentage shows how well a career aligns with your interests.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    matchInfoBullet(
                        icon: "chart.bar.fill",
                        title: "Based on Your Top Interests",
                        description: "We compare careers to your strongest interest areas (like Social, Artistic, etc.)"
                    )

                    matchInfoBullet(
                        icon: "sparkles",
                        title: "Higher = Better Fit",
                        description: "90%+ means this career strongly matches your interests. 70-89% is a good match. Below 70% may not align well."
                    )

                    matchInfoBullet(
                        icon: "graduationcap.fill",
                        title: "Real Career Data",
                        description: "Powered by O*NET, the most comprehensive database of occupational information."
                    )
                }
                .padding(.top, 8)

                Spacer()

                Button(action: {
                    showMatchPercentageInfo = false
                }) {
                    Text("Got it!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showMatchPercentageInfo = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func matchInfoBullet(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
                    
                    #if DEBUG
                    NavigationLink(destination: ConversationAnalyticsDashboard()) {
                        Text("Conversation Analytics")
                    }
                    #endif
                    
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
        NavigationLink(destination: ONetCareerDetailView(careerTrack: track)) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(track.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        Spacer()

                        // O*NET badge if available
                        if track.hasONetData {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                        }
                    }

                    if let riasecMatch = track.riasecMatch {
                        Text(riasecMatch)
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    } else {
                        Text("Progress: \(track.progress)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress bar (only show if no O*NET data)
                if !track.hasONetData {
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
                }

                HStack(spacing: 12) {
                    // Match percentage (larger for O*NET)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Match")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("\(track.match)%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }

                    Spacer()

                    // Tap indicator
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: 240)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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

                Button(action: {
                    showMatchPercentageInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {}) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }

            // Recommended careers list - show O*NET careers from Snowflake
            VStack(spacing: 12) {
                ForEach(Array(viewModel.careerTracks.prefix(3))) { track in
                    NavigationLink(destination: ONetCareerDetailView(careerTrack: track)) {
                        recommendedCareerRow(track: track)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Fallback to empty state if no careers
                if viewModel.careerTracks.isEmpty {
                    Text("Complete your profile to get personalized recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }

    private func recommendedCareerRow(track: CareerTrack) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(track.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    // O*NET badge
                    if track.hasONetData {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                }

                if let riasecMatch = track.riasecMatch {
                    Text(riasecMatch)
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                } else {
                    Text("Based on your interests and skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(track.match)%")
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