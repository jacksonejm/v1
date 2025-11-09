import SwiftUI

struct MainAppView: View {
    @ObservedObject var viewModel: AppViewModel
    @StateObject private var tracksViewModel: CareerTracksViewModel
    @State private var selectedTab = 0
    @State private var showMatchPercentageInfo = false

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        self._tracksViewModel = StateObject(wrappedValue: CareerTracksViewModel(appViewModel: viewModel))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardView
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            exploreView
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)

            aiCoachView
                .tabItem {
                    Image(systemName: "bubble.left.fill")
                    Text("AI Coach")
                }
                .tag(2)

            profileView
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
        .background(AppGradient.background.ignoresSafeArea())
    }
    
    // MARK: - Tab Views
    
    private var dashboardView: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xxxl) {
                    heroHeader
                    quickActionsStrip
                    yourTrackedCareersSection
                        .modernCard()
                    recommendedCareersSection
                        .modernCard()
                    learningResourcesSection
                        .modernCard()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .background(AppGradient.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showMatchPercentageInfo) {
                matchPercentageInfoSheet
            }
        }
        .environmentObject(viewModel)
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            Text(greetingTitle)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)

            Text("Let’s build momentum on your career journey today.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))

            HStack(spacing: Spacing.large) {
                progressPill(title: "Tracks Active", value: "\(tracksViewModel.activeTracks.count)")
                progressPill(title: "Top Match", value: topMatchLabel)
                Spacer(minLength: 0)
            }
        }
        .padding(Spacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppGradient.hero
                .mask(
                    RoundedRectangle(cornerRadius: AppCornerRadius.section, style: .continuous)
                )
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: "sparkles")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
                .padding(Spacing.xl)
        }
    }

    private func progressPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, Spacing.small)
        .padding(.horizontal, Spacing.large)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private var greetingTitle: String {
        if let name = viewModel.userData[.name] as? String, !name.isEmpty {
            return "Hi, \(name)!"
        }
        return "Welcome back"
    }

    private var topMatchLabel: String {
        guard let topTrack = viewModel.careerTracks.first else {
            return "—"
        }
        return "\(topTrack.match)%"
    }

    private var quickActionsStrip: some View {
        ModernQuickActionsView(
            viewModel: viewModel,
            selectedTab: $selectedTab,
            onShowMatchInfo: { showMatchPercentageInfo = true }
        )
        .modernCard()
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
            VStack(spacing: Spacing.xxxl) {
                Spacer()

                VStack(spacing: Spacing.large) {
                    Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppColors.accentPurple)

                    Text("Talk to your AI career coach")
                        .font(.system(size: 24, weight: .semibold))
                        .multilineTextAlignment(.center)

                    Text("Ask for guidance, plan your next steps, or rewrite goals together.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)

                Button(action: {
                    // Show AI assistant
                }) {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "sparkles")
                        Text("Open Assistant")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(AppGradient.hero)
                    .foregroundColor(.white)
                    .cornerRadius(AppCornerRadius.pill)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .background(AppGradient.background.ignoresSafeArea())
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

    private var yourTrackedCareersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            HStack {
                Text("Your Career Tracks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if tracksViewModel.activeTracks.count > 2 {
                    Button(action: {
                        // Navigate to all tracks view (future)
                    }) {
                        Text("See all")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, Spacing.large)
                            .padding(.vertical, Spacing.small)
                            .background(AppColors.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            Text("Plan milestone-based steps for the roles you care about most.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)

            if tracksViewModel.activeTracks.isEmpty {
                // Empty state
                emptyTracksCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tracksViewModel.activeTracks.prefix(3)) { track in
                            trackedCareerCard(track)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func emptyTracksCard() -> some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: "target")
                .font(.system(size: 52))
                .foregroundColor(.white)
                .padding(Spacing.small)
                .background(Circle().fill(AppColors.primary.opacity(0.25)))

            VStack(spacing: Spacing.small) {
                Text("Start tracking a career")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text("Choose a recommendation and we’ll build a plan together.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            if let firstCareer = viewModel.careerTracks.first {
                let topMatchIds = MatchBucketing.identifyTopMatches(in: viewModel.careerTracks)
                let isTopMatch = topMatchIds.contains(firstCareer.id)

                NavigationLink(destination: ONetCareerDetailView(
                    careerTrack: firstCareer,
                    isTopMatch: isTopMatch,
                    tracksViewModel: tracksViewModel
                )) {
                    Text("Browse recommendations")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.pill)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Explore careers")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.pill)
                }
            }
        }
        .padding(.vertical, 36)
        .padding(.horizontal, 28)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .fill(AppGradient.hero)
        )
    }

    private func trackedCareerCard(_ track: CareerTrack) -> some View {
        let topMatchIds = MatchBucketing.identifyTopMatches(in: viewModel.careerTracks)
        let isTopMatch = topMatchIds.contains(track.id)

        return VStack(alignment: .leading, spacing: Spacing.large) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(displayTitle(for: track))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)

                    Text("Progress overview")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                if isTopMatch {
                    TopMatchBadge(size: .small)
                } else {
                    MatchPill(tier: track.matchTier, size: .small)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text("\(Int(track.trackProgress * 100))% complete")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Text("\(track.completedTaskCount)/\(track.totalTaskCount) tasks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }

                GeometryReader { geometry in
                    Capsule()
                        .fill(AppColors.surfaceVariant.opacity(0.5))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(AppGradient.hero)
                                .frame(width: geometry.size.width * track.trackProgress)
                        }
                        .frame(height: 8)
                }
                .frame(height: 8)
            }

            if let nextStep = track.nextSteps.first {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 16))

                    Text("Next: \(nextStep.title)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            NavigationLink(destination: TrackDetailView(
                track: track,
                isTopMatch: isTopMatch,
                tracksViewModel: tracksViewModel
            )) {
                HStack(spacing: Spacing.small) {
                    Text("Continue plan")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppGradient.hero)
                .cornerRadius(AppCornerRadius.pill)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.xl)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .fill(AppColors.surfacePrimary)
                .shadow(color: AppShadow.subtle, radius: 16, x: 0, y: 14)
        )
    }

    private var recommendedCareersSection: some View {
        let topMatchIds = MatchBucketing.identifyTopMatches(in: viewModel.careerTracks)
        let sortedTracks = sortCareersByTier(viewModel.careerTracks, topMatchIds: topMatchIds)

        return VStack(alignment: .leading, spacing: Spacing.large) {
            HStack {
                Text("Recommended For You")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Button(action: {
                    showMatchPercentageInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                NavigationLink(destination: AllRecommendationsView(viewModel: viewModel)) {
                    Text("See all")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, Spacing.large)
                        .padding(.vertical, Spacing.small)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Text("Refreshed whenever you update interests, work values, or activities.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)

            VStack(spacing: Spacing.small) {
                ForEach(Array(sortedTracks.prefix(3).enumerated()), id: \.element.id) { index, track in
                    let isTop = topMatchIds.contains(track.id)
                    NavigationLink(destination: ONetCareerDetailView(
                        careerTrack: track,
                        isTopMatch: isTop,
                        tracksViewModel: tracksViewModel
                    )) {
                        recommendedCareerRow(track: track, isTopMatch: isTop)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Fallback to empty state if no careers
                if viewModel.careerTracks.isEmpty {
                    Text("Complete onboarding to unlock personalized matches.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                                .fill(AppColors.surfaceSecondary.opacity(0.6))
                        )
                }
            }
        }
    }

    private func recommendedCareerRow(track: CareerTrack, isTopMatch: Bool) -> some View {
        HStack(alignment: .center, spacing: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(spacing: Spacing.small) {
                    Text(displayTitle(for: track))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    if track.hasONetData {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }

                Text("Matches your interests and skills")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(track.match)%")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                if isTopMatch {
                    TopMatchBadge(size: .small)
                } else {
                    MatchPill(tier: track.matchTier, size: .small)
                }
            }
        }
        .padding(.vertical, Spacing.medium)
        .padding(.horizontal, Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .fill(AppColors.surfaceSecondary.opacity(0.65))
        )
    }
    
    private var learningResourcesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            HStack {
                Text("Learning Resources")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See all")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, Spacing.large)
                        .padding(.vertical, Spacing.small)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            Text("Short, curated lessons to close gaps and build career confidence.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            
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
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 32))
                .foregroundColor(AppColors.accentPurple)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)

            Spacer(minLength: 0)

            HStack {
                Text(type)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.accentPurple.opacity(0.12))
                    .foregroundColor(AppColors.accentPurple)
                    .clipShape(Capsule())

                Spacer()

                Text(duration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(Spacing.large)
        .frame(width: 200, height: 170)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .fill(AppColors.surfaceSecondary.opacity(0.7))
        )
    }
    
    // MARK: - Helper Properties

    private var userName: String {
        if let name = viewModel.userData[.name] as? String, !name.isEmpty {
            return name
        }
        return "Explorer"
    }

    /// Sort careers by match quality: Top matches first, then High/Medium/Low tiers
    private func sortCareersByTier(_ careers: [CareerTrack], topMatchIds: Set<UUID>) -> [CareerTrack] {
        return careers.sorted { first, second in
            let firstIsTop = topMatchIds.contains(first.id)
            let secondIsTop = topMatchIds.contains(second.id)

            // Top matches always come first
            if firstIsTop != secondIsTop {
                return firstIsTop
            }

            // If both are top matches, sort by score descending
            if firstIsTop && secondIsTop {
                return first.match > second.match
            }

            // For non-top matches, sort by tier then by score
            let firstTier = first.matchTier
            let secondTier = second.matchTier

            if firstTier != secondTier {
                // High > Medium > Low
                let tierOrder: [MatchTier: Int] = [.high: 0, .medium: 1, .low: 2]
                return tierOrder[firstTier]! < tierOrder[secondTier]!
            }

            // Within same tier, sort by score descending
            return first.match > second.match
        }
    }

    // MARK: - Display Helpers

    /// Get display title for a career (prefers Canadian title when available)
    private func displayTitle(for track: CareerTrack) -> String {
        // Check if user is Canadian and if we have Canadian data
        if viewModel.userCountry.usesNOC,
           let onetCode = track.onetCode,
           let canadianOcc = viewModel.canadianOccupationData[onetCode],
           let canadianTitle = canadianOcc.canadianTitle {
            return canadianTitle
        }
        return track.title
    }
}

// MARK: - Supporting Components

struct ModernQuickActionsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var selectedTab: Int
    var onShowMatchInfo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            Text("Jump back in")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            Text("Pick up where you left off or refresh your matches with one tap.")
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)

            VStack(spacing: Spacing.small) {
                quickActionButton(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Refresh matches",
                    subtitle: "Update recommendations",
                    action: refreshMatches
                )

                quickActionButton(
                    icon: "list.bullet.rectangle",
                    title: "Manage tracks",
                    subtitle: "Plan next milestones",
                    action: { selectedTab = 1 }
                )

                quickActionButton(
                    icon: "chart.pie.fill",
                    title: "How we score",
                    subtitle: "Understand your match %",
                    action: onShowMatchInfo
                )
            }
        }
    }

    private func quickActionButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.large) {
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceSecondary)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(.vertical, Spacing.small)
            .padding(.horizontal, Spacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.pill, style: .continuous)
                    .fill(AppColors.surfaceSecondary.opacity(0.65))
            )
        }
        .buttonStyle(.plain)
    }

    private func refreshMatches() {
        Task {
            await viewModel.generateCareerSuggestions()
        }
    }
}
