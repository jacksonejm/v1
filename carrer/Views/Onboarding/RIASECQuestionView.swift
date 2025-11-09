import SwiftUI

struct RIASECQuestionView: View {
    @ObservedObject var viewModel: AppViewModel
    let dimension: RIASECDimension
    
    // Use a @State property wrapper that's initialized from the global state
    // but updates immediately when changed to provide responsive UI
    @State private var responses: [String: Int] = [:]
    
    private var questions: [String] {
        dimension.questions
    }
    
    var body: some View {
        VStack(spacing: Spacing.large) {
            Text("Rate each statement to map how strongly you identify with this interest area.")
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)

            ScrollView {
                VStack(spacing: Spacing.large) {
                    ForEach(questions, id: \.self) { question in
                        questionCard(for: question)
                    }
                }
                .padding(.vertical, Spacing.small)
            }
        }
        .onAppear {
            loadSavedResponses()
            print("RIASECQuestionView appeared for \(dimension.rawValue) dimension")
        }
        .id("riasec-\(dimension.rawValue)")
    }

    private func questionCard(for question: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(question)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Spacing.medium) {
                ForEach(1...5, id: \.self) { rating in
                    let isSelected = responses[question] == rating

                    Button(action: {
                        responses[question] = rating
                        updateRIASECResponses()
                    }) {
                        Text("\(rating)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(AppColors.surfaceSecondary.opacity(0.85))
                                    .overlay(
                                        Circle()
                                            .fill(AppGradient.hero)
                                            .opacity(isSelected ? 1 : 0)
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.white.opacity(0.7) : AppColors.surfaceVariant.opacity(0.6), lineWidth: isSelected ? 1 : 0)
                            )
                            .shadow(color: isSelected ? AppShadow.subtle : Color.clear, radius: isSelected ? 10 : 0, x: 0, y: isSelected ? 6 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("Strongly Disagree")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("Strongly Agree")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .fill(AppColors.surfaceSecondary.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .strokeBorder(AppColors.surfaceVariant.opacity(0.4), lineWidth: 1)
        )
    }
    
    private func updateRIASECResponses() {
        // Use the centralized method in the viewModel to ensure consistent state
        // This ensures all screens use the same state management approach
        viewModel.updateRIASECResponses(dimension: dimension, responses: responses)
        
        // Debug info
        let answeredInThisDimension = responses.count
        let totalQuestions = questions.count
        print("Updated RIASEC responses: \(answeredInThisDimension)/\(totalQuestions) questions answered in '\(dimension.rawValue)' dimension")
    }
    
    private func loadSavedResponses() {
        // First clear responses to avoid showing stale data
        responses = [:]
        
        print("Loading responses for \(dimension.rawValue) dimension")
        
        // APPROACH 1: Try to load from the strongly-typed structure first
        if let allResponses = viewModel.userData[.riasecResponses] as? [String: [String: Int]] {
            if let dimensionResponses = allResponses[dimension.rawValue] {
                responses = dimensionResponses
                print("APPROACH 1: Loaded \(responses.count) responses for \(dimension.rawValue) from strong typing")
                return
            }
        }
        
        // APPROACH 2: Try to load from the generic structure (legacy format)
        if let allDimensionsResponses = viewModel.userData[.riasecResponses] as? [String: Any] {
            if let dimensionObj = allDimensionsResponses[dimension.rawValue] {
                if let dimensionDict = dimensionObj as? [String: Int] {
                    // Direct [String: Int] format
                    responses = dimensionDict
                    print("APPROACH 2A: Loaded \(responses.count) responses for \(dimension.rawValue) from direct dictionary")
                    return
                } else if let dictAny = dimensionObj as? [String: Any] {
                    // Convert [String: Any] to [String: Int]
                    for (key, value) in dictAny {
                        if let intValue = value as? Int {
                            responses[key] = intValue
                        }
                    }
                    print("APPROACH 2B: Loaded \(responses.count) responses for \(dimension.rawValue) from converted dictionary")
                    return
                }
            }
        }
        
        // APPROACH 3: Try the flattened format as the last resort
        if let flatResponses = viewModel.userData[.riasecResponsesFlat] as? [String: Int] {
            // Only extract questions relevant to this dimension
            var found = false
            for question in questions {
                if let rating = flatResponses[question] {
                    responses[question] = rating
                    found = true
                }
            }
            
            if found {
                print("APPROACH 3: Loaded \(responses.count) responses for \(dimension.rawValue) from flattened dictionary")
                
                // IMPORTANT: Save these back to the dimension-specific structure
                // This ensures that future loads will use the more specific approach
                self.updateRIASECResponses()
                
                return
            }
        }
        
        print("No existing responses found for \(dimension.rawValue)")
    }
}
