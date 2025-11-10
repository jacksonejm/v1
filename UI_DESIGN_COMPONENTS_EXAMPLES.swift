// Alternative UI Design Components for MyPath
// SwiftUI Implementation Examples
// Based on 2025 Design Trends

import SwiftUI

// MARK: - Design #1: Liquid Glass Components

struct LiquidGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Blurred glass background
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .background(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            content
                .padding(20)
        }
        .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
    }
}

struct LiquidGlassCareerCard: View {
    let title: String
    let matchPercentage: Int
    let interests: Int
    let values: Int
    let skills: Int
    let context: Int

    @State private var animateMatch = false

    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Text("\(matchPercentage)%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("✨")
                }

                // Animated Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: animateMatch ? CGFloat(matchPercentage) / 100 : 0)
                        .stroke(
                            AngularGradient(
                                colors: [.blue, .purple, .pink, .blue],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 1.5), value: animateMatch)

                    VStack(spacing: 4) {
                        Text("\(matchPercentage)%")
                            .font(.system(size: 32, weight: .bold))
                        Text("MATCH")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

                // Match Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Match Breakdown")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)

                    MatchBar(label: "🎯 Interests", value: interests)
                    MatchBar(label: "💎 Values", value: values)
                    MatchBar(label: "🛠️ Skills", value: skills)
                    MatchBar(label: "🎓 Context", value: context)
                }

                // Action Button
                Button(action: {}) {
                    HStack {
                        Text("Explore Career")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .onAppear {
            animateMatch = true
        }
    }
}

struct MatchBar: View {
    let label: String
    let value: Int
    @State private var animateBar = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .frame(width: 120, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: value),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateBar ? geometry.size.width * CGFloat(value) / 100 : 0)
                        .animation(.spring(duration: 1), value: animateBar)
                }
            }
            .frame(height: 8)

            Text("\(value)%")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 45, alignment: .trailing)
        }
        .onAppear {
            animateBar = true
        }
    }

    func gradientColors(for value: Int) -> [Color] {
        if value >= 80 {
            return [.green, .mint]
        } else if value >= 60 {
            return [.blue, .cyan]
        } else {
            return [.gray, .secondary]
        }
    }
}

// MARK: - Design #2: Gamified Components

struct GameifiedCareerCard: View {
    let title: String
    let matchScore: Int
    let xpReward: Int
    let rank: String

    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: "7C3AED"),
                    Color(hex: "EC4899")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(24)

            VStack(spacing: 16) {
                // Rank Badge
                HStack {
                    RankBadge(rank: rank)
                    Spacer()
                    Text("+\(xpReward) XP")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "FCD34D"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                }

                // Career Title
                Text(title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Match Score as Boss Battle
                VStack(spacing: 8) {
                    Text("MATCH BATTLE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 20) {
                        VStack {
                            Text("YOU")
                                .font(.system(size: 14, weight: .bold))
                            Text("100%")
                                .font(.system(size: 24, weight: .black))
                        }

                        Text("VS")
                            .font(.system(size: 20, weight: .bold))

                        VStack {
                            Text("CAREER")
                                .font(.system(size: 14, weight: .bold))
                            Text("\(matchScore)%")
                                .font(.system(size: 24, weight: .black))
                        }
                    }
                    .foregroundColor(.white)

                    if matchScore >= 80 {
                        HStack {
                            Text("🎉 VICTORY!")
                                .font(.system(size: 20, weight: .black))
                            Text(rank)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "FCD34D"))
                                .foregroundColor(Color(hex: "7C3AED"))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)

                // Action Button
                Button(action: { showConfetti = true }) {
                    Text("Unlock Career Details")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "7C3AED"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(20)
        }
        .confettiCannon(counter: $showConfetti ? 1 : 0)
    }
}

struct RankBadge: View {
    let rank: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rankIcon)
                .font(.system(size: 16))
            Text(rank)
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(rankColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(rankColor.opacity(0.2))
        .cornerRadius(12)
    }

    var rankIcon: String {
        switch rank {
        case "S-Rank": return "crown.fill"
        case "A-Rank": return "star.fill"
        case "B-Rank": return "star.leadinghalf.filled"
        default: return "star"
        }
    }

    var rankColor: Color {
        switch rank {
        case "S-Rank": return Color(hex: "FCD34D")
        case "A-Rank": return Color(hex: "10B981")
        case "B-Rank": return Color(hex: "3B82F6")
        default: return .gray
        }
    }
}

struct StreakCounter: View {
    let streakDays: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("🔥")
                    .font(.system(size: 32))
                Text("\(streakDays) Day Streak!")
                    .font(.system(size: 24, weight: .black))
            }

            HStack(spacing: 16) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    VStack(spacing: 4) {
                        Text(day)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        ZStack {
                            Circle()
                                .fill(day == "Sun" ? Color.orange : Color.green)
                                .frame(width: 36, height: 36)

                            if day == "Sun" {
                                Text("🔥")
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Complete today's mini-quest:")
                    .font(.system(size: 14, weight: .semibold))

                QuestItem(completed: false, text: "Update one career preference")
                QuestItem(completed: false, text: "Explore a new occupation")
                QuestItem(completed: false, text: "Complete a skill assessment")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}

struct QuestItem: View {
    let completed: Bool
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: completed ? "checkmark.square.fill" : "square")
                .foregroundColor(completed ? .green : .gray)
            Text(text)
                .font(.system(size: 14))
        }
    }
}

// MARK: - Design #3: TikTok Swipe Components

struct SwipeableCareerCard: View {
    let title: String
    let matchPercentage: Int
    let salary: String
    let growth: String
    let education: String
    let imageName: String

    @State private var offset: CGSize = .zero
    @State private var isSwiping = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background Image with Gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Color.blue.opacity(0.3) // Placeholder for image
                    )

                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Spacer()

                    // Title
                    Text(title.uppercased())
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.white)

                    // Match Score
                    HStack {
                        Text("\(matchPercentage)% MATCH")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "00F5FF"))
                        Text("✨")
                            .font(.system(size: 24))
                    }

                    // Quick Stats
                    HStack(spacing: 20) {
                        QuickStat(icon: "💰", value: salary)
                        QuickStat(icon: "📈", value: growth)
                        QuickStat(icon: "🎓", value: education)
                    }

                    // Action Buttons
                    HStack(spacing: 40) {
                        ActionButton(icon: "heart.fill", color: Color(hex: "FF006E"))
                        ActionButton(icon: "bookmark.fill", color: Color(hex: "00F5FF"))
                        ActionButton(icon: "square.and.arrow.up", color: .white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                    // Swipe Hint
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Swipe up for more")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                }
                .padding(24)

                // Swipe Indicators
                if offset.width > 50 {
                    VStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "00F5FF"))
                        Text("SAVE")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "00F5FF").opacity(0.3))
                } else if offset.width < -50 {
                    VStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "FF006E"))
                        Text("SKIP")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "FF006E").opacity(0.3))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .cornerRadius(0)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        isSwiping = true
                    }
                    .onEnded { gesture in
                        if abs(offset.width) > 100 {
                            // Complete swipe
                            withAnimation {
                                offset = CGSize(
                                    width: offset.width > 0 ? 500 : -500,
                                    height: 0
                                )
                            }
                        } else {
                            // Return to center
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                        isSwiping = false
                    }
            )
        }
    }
}

struct QuickStat: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

// MARK: - Design #5: Emotional/Mindful Components

struct MindfulCareerCard: View {
    let title: String
    let matchPercentage: Int
    let whyFits: [String]
    let testimonial: String
    let author: String

    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Gentle reveal animation
            if revealed {
                VStack(alignment: .leading, spacing: 16) {
                    // Icon
                    Text("✨")
                        .font(.system(size: 48))
                        .transition(.scale.combined(with: .opacity))

                    // Title
                    Text(title)
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "2F2F2F"))
                        .transition(.opacity.combined(with: .offset(y: 20)))

                    // Match explained gently
                    Text("A \(matchPercentage)% match with your unique profile")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "87A96B"))
                        .transition(.opacity.combined(with: .offset(y: 20)))

                    Divider()
                        .background(Color(hex: "87A96B").opacity(0.3))

                    // Why this might fit
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why this might resonate:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2F2F2F"))

                        ForEach(whyFits, id: \.self) { reason in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(Color(hex: "87A96B"))
                                Text(reason)
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(Color(hex: "2F2F2F"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .offset(y: 20)))

                    // Testimonial
                    VStack(alignment: .leading, spacing: 8) {
                        Text(""\(testimonial)"")
                            .font(.custom("Georgia", size: 16))
                            .italic()
                            .foregroundColor(Color(hex: "2F2F2F"))

                        Text("— \(author)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(hex: "A594F9").opacity(0.1))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .offset(y: 20)))

                    // Gentle CTA
                    HStack {
                        Button(action: {}) {
                            Text("Learn More")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "87A96B"))
                                .cornerRadius(12)
                        }

                        Button(action: {}) {
                            Text("Save")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color(hex: "87A96B"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "87A96B").opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .transition(.opacity.combined(with: .offset(y: 20)))
                }
                .padding(24)
            } else {
                // Breathing moment before reveal
                VStack(spacing: 20) {
                    BreathingCircle()

                    Text("Take a moment...")
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .background(Color(hex: "FAF9F6"))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    revealed = true
                }
            }
        }
    }
}

struct BreathingCircle: View {
    @State private var breatheIn = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "87A96B").opacity(0.3),
                            Color(hex: "A594F9").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: breatheIn ? 100 : 60, height: breatheIn ? 100 : 60)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: breatheIn
                )

            Text(breatheIn ? "Breathe in..." : "Breathe out...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .onAppear {
            breatheIn = true
        }
    }
}

// MARK: - Helper Components

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(duration: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview Examples

struct DesignPreview: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Liquid Glass Example
            ScrollView {
                VStack(spacing: 20) {
                    LiquidGlassCareerCard(
                        title: "Software Developer",
                        matchPercentage: 89,
                        interests: 92,
                        values: 88,
                        skills: 90,
                        context: 85
                    )
                    .padding()
                }
            }
            .tabItem {
                Label("Liquid Glass", systemImage: "sparkles")
            }
            .tag(0)

            // Gamified Example
            ScrollView {
                VStack(spacing: 20) {
                    GameifiedCareerCard(
                        title: "UX Designer",
                        matchScore: 89,
                        xpReward: 350,
                        rank: "S-Rank"
                    )
                    .padding()

                    StreakCounter(streakDays: 7)
                        .padding()
                }
            }
            .tabItem {
                Label("Gamified", systemImage: "gamecontroller.fill")
            }
            .tag(1)

            // TikTok Swipe Example
            SwipeableCareerCard(
                title: "Data Analyst",
                matchPercentage: 86,
                salary: "$78K",
                growth: "+23%",
                education: "Bachelor's",
                imageName: "placeholder"
            )
            .tabItem {
                Label("Swipe", systemImage: "hand.draw.fill")
            }
            .tag(2)

            // Mindful Example
            ScrollView {
                VStack(spacing: 20) {
                    MindfulCareerCard(
                        title: "Software Developer",
                        matchPercentage: 89,
                        whyFits: [
                            "Matches your investigative nature",
                            "Allows for creative problem-solving",
                            "Offers the independence you value"
                        ],
                        testimonial: "I wake up excited to solve new challenges every day.",
                        author: "Alex, Software Developer"
                    )
                    .padding()
                }
            }
            .tabItem {
                Label("Mindful", systemImage: "leaf.fill")
            }
            .tag(3)
        }
    }
}

// Note: For confetti effect in gamified design, consider adding:
// https://github.com/simibac/ConfettiSwiftUI
// or implement a custom particle system
