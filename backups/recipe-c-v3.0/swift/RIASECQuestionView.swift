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
        VStack(spacing: 16) {
            // Description
            Text("How much do you agree with each statement? This will help us understand your \(dimension.rawValue.lowercased()) interests.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(questions, id: \.self) { question in
                        questionCard(for: question)
                    }
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            loadSavedResponses()
            print("RIASECQuestionView appeared for \(dimension.rawValue) dimension")
        }
        .id("riasec-\(dimension.rawValue)")
    }

    private func questionCard(for question: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)


            HStack(spacing: 0) {
                ForEach(1..<6) { rating in
                    if rating > 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .padding(.horizontal, 4)
                    }

                    Button(action: {
                        responses[question] = rating
                        updateRIASECResponses()
                    }) {
                        ZStack {
                            Circle()
                                .fill(responses[question] == rating ? AppColors.primary : Color.gray.opacity(0.15))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.primary, lineWidth: responses[question] == rating ? 3 : 0)
                                )
                                .shadow(
                                    color: responses[question] == rating ? AppColors.primary.opacity(0.3) : Color.clear,
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )

                            Text("\(rating)")
                                .foregroundColor(responses[question] == rating ? .white : .primary)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack {
                Text("Strongly Disagree")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Strongly Agree")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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