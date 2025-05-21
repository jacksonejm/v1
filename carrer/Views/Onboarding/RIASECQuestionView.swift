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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Removed duplicate header - already provided by OnboardingView

                Text("How much do you agree with each statement? This will help us understand your \(dimension.rawValue.lowercased()) interests.")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            
            ForEach(questions, id: \.self) { question in
                VStack(alignment: .leading, spacing: 8) {
                    Text(question)
                        .font(.body)
                        .padding(.bottom, 4)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            ForEach(1..<6) { rating in
                                // Add a connecting line before each circle except the first one
                                if rating > 1 {
                                    // Line connecting the previous and current circle
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 2)
                                        .padding(.horizontal, 5)
                                }
                                
                                Button(action: {
                                    responses[question] = rating
                                    updateRIASECResponses()
                                }) {
                                    ZStack {
                                        // Actual colored circle on top
                                        Circle()
                                            .fill(responses[question] == rating ? Color.blue : Color.gray.opacity(0.2))
                                            .frame(width: 46, height: 46)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.blue, lineWidth: responses[question] == rating ? 4 : 0)
                                            )
                                            .shadow(
                                                color: responses[question] == rating ? Color.blue.opacity(0.3) : Color.clear,
                                                radius: 4,
                                                x: 0,
                                                y: 2
                                            )
                                        
                                        Text("\(rating)")
                                            .foregroundColor(responses[question] == rating ? .white : .primary)
                                            .font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        HStack(spacing: 0) {
                            Text("Strongly Disagree")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Text("Strongly Agree")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            }
            .padding()
        }
        .onAppear {
            loadSavedResponses()
            print("RIASECQuestionView appeared for \(dimension.rawValue) dimension")
        }
        // This modifier ensures the view is reconstructed when the dimension changes
        // even if the struct type remains the same
        .id("riasec-\(dimension.rawValue)")
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