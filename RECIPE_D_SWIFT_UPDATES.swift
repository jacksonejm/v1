// =============================================
// Recipe D v4.0 - Student-Friendly Swift Updates
// =============================================
// Update OnboardingView.swift with student-friendly subject/activity names
// Adds 5 subjects + 5 activities for 91% skills coverage
// =============================================

import SwiftUI

// MARK: - Updated School Subjects (13 total)
struct SchoolSubject: Identifiable, Hashable {
    let id = UUID()
    let name: String

    static let allSubjects: [SchoolSubject] = [
        // ========== ORIGINAL (8) ==========
        SchoolSubject(name: "Math"),
        SchoolSubject(name: "Science"),
        SchoolSubject(name: "Art"),
        SchoolSubject(name: "History"),
        SchoolSubject(name: "English"),
        SchoolSubject(name: "Technology"),
        SchoolSubject(name: "Physical Education"),

        // ========== NEW (5) - Student-Friendly ==========
        SchoolSubject(name: "Business/Economics"),
        SchoolSubject(name: "Computer Programming"),
        SchoolSubject(name: "Psychology"),
        SchoolSubject(name: "Biology"),
        SchoolSubject(name: "World Languages"),

        // ========== OTHER ==========
        SchoolSubject(name: "Other")
    ]

    // Optional: Group subjects by category for better UI
    static let subjectCategories: [String: [SchoolSubject]] = [
        "STEM": [
            SchoolSubject(name: "Math"),
            SchoolSubject(name: "Science"),
            SchoolSubject(name: "Biology"),
            SchoolSubject(name: "Computer Programming"),
            SchoolSubject(name: "Technology")
        ],
        "Humanities": [
            SchoolSubject(name: "English"),
            SchoolSubject(name: "History"),
            SchoolSubject(name: "World Languages")
        ],
        "Social Sciences": [
            SchoolSubject(name: "Psychology")
        ],
        "Business & Creative": [
            SchoolSubject(name: "Business/Economics"),
            SchoolSubject(name: "Art")
        ],
        "Other": [
            SchoolSubject(name: "Physical Education"),
            SchoolSubject(name: "Other")
        ]
    ]
}

// MARK: - Updated Activities (12 total)
struct Activity: Identifiable, Hashable {
    let id = UUID()
    let name: String

    static let allActivities: [Activity] = [
        // ========== ORIGINAL (7) ==========
        Activity(name: "Robotics Club"),
        Activity(name: "Drama or Theatre"),
        Activity(name: "Sports"),
        Activity(name: "Debate Team"),
        Activity(name: "Volunteering"),
        Activity(name: "Music or Band"),

        // ========== NEW (5) - Student-Friendly ==========
        Activity(name: "Student Council"),
        Activity(name: "Business Club/DECA"),
        Activity(name: "Auto Shop/Mechanics"),
        Activity(name: "Model UN"),
        Activity(name: "Event Planning/School Events"),

        // ========== OTHER ==========
        Activity(name: "Other")
    ]

    // Optional: Group activities by category for better UI
    static let activityCategories: [String: [Activity]] = [
        "Leadership": [
            Activity(name: "Student Council"),
            Activity(name: "Event Planning/School Events")
        ],
        "Clubs & Organizations": [
            Activity(name: "Robotics Club"),
            Activity(name: "Business Club/DECA"),
            Activity(name: "Model UN"),
            Activity(name: "Debate Team")
        ],
        "Arts & Performance": [
            Activity(name: "Drama or Theatre"),
            Activity(name: "Music or Band")
        ],
        "Service & Community": [
            Activity(name: "Volunteering")
        ],
        "Technical & Sports": [
            Activity(name: "Auto Shop/Mechanics"),
            Activity(name: "Sports")
        ],
        "Other": [
            Activity(name: "Other")
        ]
    ]
}

// MARK: - Updated FavoriteSubjectsView with Grouping (Optional)

struct FavoriteSubjectsViewGrouped: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedSubjects: Set<SchoolSubject> = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Select up to 3 subjects you enjoy the most.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Option 1: Show all subjects in a flat list
                    ForEach(SchoolSubject.allSubjects) { subject in
                        subjectButton(subject)
                    }

                    // Option 2: Group by category (comment out Option 1 and use this)
                    /*
                    ForEach(["STEM", "Humanities", "Social Sciences", "Business & Creative", "Other"], id: \.self) { category in
                        if let subjects = SchoolSubject.subjectCategories[category] {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)

                                ForEach(subjects) { subject in
                                    subjectButton(subject)
                                }
                            }
                        }
                    }
                    */
                }
            }

            // Selection Counter
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index < selectedSubjects.count ? AppColors.primary : Color.gray.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                Text("\(selectedSubjects.count)/3 selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
        }
        .padding()
        .onChange(of: selectedSubjects) { newValue in
            viewModel.userData[.favoriteSubjects] = newValue
        }
        .onAppear {
            if let saved = viewModel.userData[.favoriteSubjects] as? Set<SchoolSubject> {
                selectedSubjects = saved
            }
        }
    }

    private func subjectButton(_ subject: SchoolSubject) -> some View {
        SelectionButton(
            title: subject.name,
            isSelected: selectedSubjects.contains(subject),
            action: {
                if selectedSubjects.contains(subject) {
                    selectedSubjects.remove(subject)
                } else if selectedSubjects.count < 3 {
                    selectedSubjects.insert(subject)
                }
            }
        )
    }
}

// MARK: - Updated ExtracurricularActivitiesView with Grouping (Optional)

struct ExtracurricularActivitiesViewGrouped: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedActivities: Set<Activity> = []
    @State private var otherActivity: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Select any activities that interest you.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Option 1: Show all activities in a flat list
                    ForEach(Activity.allActivities) { activity in
                        activityButton(activity)
                    }

                    // Option 2: Group by category (comment out Option 1 and use this)
                    /*
                    ForEach(["Leadership", "Clubs & Organizations", "Arts & Performance", "Service & Community", "Technical & Sports", "Other"], id: \.self) { category in
                        if let activities = Activity.activityCategories[category] {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)

                                ForEach(activities) { activity in
                                    activityButton(activity)
                                }
                            }
                        }
                    }
                    */
                }
            }
        }
        .padding()
        .onChange(of: selectedActivities) { newValue in
            viewModel.userData[.extracurriculars] = newValue
        }
        .onChange(of: otherActivity) { newValue in
            viewModel.userData[.extracurricularOther] = newValue
        }
        .onAppear {
            if let saved = viewModel.userData[.extracurriculars] as? Set<Activity> {
                selectedActivities = saved
            }
            if let savedOther = viewModel.userData[.extracurricularOther] as? String {
                otherActivity = savedOther
            }
        }
    }

    private func activityButton(_ activity: Activity) -> some View {
        VStack(spacing: 0) {
            SelectionButton(
                title: activity.name,
                isSelected: selectedActivities.contains(activity),
                action: {
                    if selectedActivities.contains(activity) {
                        selectedActivities.remove(activity)
                        if activity.name == "Other" {
                            otherActivity = ""
                        }
                    } else {
                        selectedActivities.insert(activity)
                    }
                }
            )

            if activity.name == "Other" && selectedActivities.contains(activity) {
                TextField("Enter your activity", text: $otherActivity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Implementation Instructions

/*

 TO IMPLEMENT THESE CHANGES:

 1. Open: carrer/Views/Onboarding/OnboardingView.swift

 2. Replace the SchoolSubject struct (around line 1202) with the updated version above

 3. Replace the Activity struct (around line 1306) with the updated version above

 4. (Optional) Replace FavoriteSubjectsView with FavoriteSubjectsViewGrouped if you want grouped UI

 5. (Optional) Replace ExtracurricularActivitiesView with ExtracurricularActivitiesViewGrouped if you want grouped UI

 6. Run the Snowflake SQL: RECIPE_D_ADD_STUDENT_FRIENDLY_MAPPINGS.sql

 7. Test in the app:
    - Complete onboarding
    - Select new subjects/activities
    - Verify skills matching improves

 NOTES:
 - Grouping is optional but recommended for better UX with 20 options
 - Student-friendly names match what high schoolers actually say
 - All mappings are already in Snowflake (RECIPE_D_COMPLETE_MAPPINGS.sql)
 - Coverage increases from 66% → 91%

 */

// MARK: - Help Text for New Options (Optional)

extension HelpSheetView {
    private var enhancedHelpContent: String {
        switch step {
        case .favoriteSubjects:
            return """
            Your favorite subjects provide insights into the fields where you might excel.

            NEW SUBJECTS:
            • Business/Economics: Learn about markets, finance, and management
            • Computer Programming: Learn to code and build software
            • Psychology: Study how people think and behave
            • Biology: Study living organisms and life sciences
            • World Languages: Learn Spanish, French, Mandarin, or other languages
            """

        case .extracurriculars:
            return """
            Activities outside of class reveal additional skills and interests.

            NEW ACTIVITIES:
            • Student Council: Lead your class or school government
            • Business Club/DECA: Business competitions and entrepreneurship
            • Auto Shop/Mechanics: Learn to repair and maintain vehicles
            • Model UN: Debate global issues and practice diplomacy
            • Event Planning: Organize dances, fundraisers, or school events
            """

        default:
            return helpContent // Original content
        }
    }
}
