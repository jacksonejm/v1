import SwiftUI

/// Work Values assessment view
/// Collects user's 6 work values scores (1-5 scale) for Recipe C matching
struct WorkValuesView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var values: [WorkValue: Double] = [
        .achievement: 3.0,
        .independence: 3.0,
        .recognition: 3.0,
        .relationships: 3.0,
        .support: 3.0,
        .workingConditions: 3.0
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Description
            Text("Rate how important each value is to you in a career. This helps us find careers that truly match what you're looking for.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(WorkValue.allCases, id: \.self) { value in
                        workValueSlider(for: value)
                    }
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            // Load saved values if they exist, otherwise save defaults
            if let savedValues = viewModel.userData[.workValues] as? [String: Double] {
                for (key, value) in savedValues {
                    if let workValue = WorkValue.allCases.first(where: { $0.key == key }) {
                        values[workValue] = value
                    }
                }
                print("📊 Loaded saved work values: \(savedValues.count) values")
            } else {
                // Save initial default values
                saveWorkValues()
                print("📊 Initialized work values with defaults (all 3.0)")
            }
        }
    }

    private func workValueSlider(for value: WorkValue) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: value.icon)
                    .font(.body)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(value.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(value.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Text("Not Important")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)

                Slider(value: Binding(
                    get: { values[value] ?? 3.0 },
                    set: { newValue in
                        values[value] = newValue
                        saveWorkValues()
                    }
                ), in: 1...5, step: 1)
                .accentColor(AppColors.primary)

                Text("Very Important")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .trailing)
            }

            // Value indicator dots
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(Double(level) <= (values[value] ?? 3.0) ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func saveWorkValues() {
        // Save work values to userData whenever a slider changes
        var workValuesData: [String: Double] = [:]
        for (value, score) in values {
            workValuesData[value.key] = score
        }

        viewModel.userData[.workValues] = workValuesData as AnyHashable

        print("📊 Work Values updated: \(workValuesData.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))")
    }
}

// MARK: - Work Value Model

enum WorkValue: String, CaseIterable {
    case achievement
    case independence
    case recognition
    case relationships
    case support
    case workingConditions

    var key: String {
        switch self {
        case .achievement: return "achievement"
        case .independence: return "independence"
        case .recognition: return "recognition"
        case .relationships: return "relationships"
        case .support: return "support"
        case .workingConditions: return "working_conditions"
        }
    }

    var title: String {
        switch self {
        case .achievement:
            return "Achievement"
        case .independence:
            return "Independence"
        case .recognition:
            return "Recognition & Status"
        case .relationships:
            return "Helping Others"
        case .support:
            return "Supportive Environment"
        case .workingConditions:
            return "Job Security & Conditions"
        }
    }

    var description: String {
        switch self {
        case .achievement:
            return "Accomplishment, results, using my abilities"
        case .independence:
            return "Autonomy, creativity, working on my own"
        case .recognition:
            return "Prestige, authority, advancement opportunities"
        case .relationships:
            return "Service to others, making a difference"
        case .support:
            return "Pleasant coworkers, supportive management"
        case .workingConditions:
            return "Security, compensation, variety, good conditions"
        }
    }

    var icon: String {
        switch self {
        case .achievement:
            return "trophy.fill"
        case .independence:
            return "person.fill"
        case .recognition:
            return "star.fill"
        case .relationships:
            return "heart.fill"
        case .support:
            return "hands.sparkles.fill"
        case .workingConditions:
            return "building.2.fill"
        }
    }

    /// Maps to O*NET Work Values Element IDs
    var onetElementID: String {
        switch self {
        case .achievement: return "1.B.2.a"
        case .workingConditions: return "1.B.2.b"
        case .recognition: return "1.B.2.c"
        case .relationships: return "1.B.2.d"
        case .support: return "1.B.2.e"
        case .independence: return "1.B.2.f"
        }
    }
}

#Preview {
    NavigationStack {
        WorkValuesView(viewModel: AppViewModel())
    }
}
