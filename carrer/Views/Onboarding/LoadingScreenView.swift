//import SwiftUI
//
//struct LoadingScreenView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @EnvironmentObject private var store: OnboardingStore
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            ProgressView()
//                .scaleEffect(1.5)
//                .padding()
//            
//            Text("Processing your responses...")
//                .font(.title3)
//                .foregroundColor(.secondary)
//            
//            Text("We're analyzing your answers to find the best career matches for you.")
//                .multilineTextAlignment(.center)
//                .foregroundColor(.gray)
//                .padding(.horizontal, 40)
//                .padding(.top, 10)
//            
//            // Automatically advance to next step after generating career suggestions
//            // This is handled in OnboardingView's navigateToNextStep() method
//        }
//        .padding()
//        .onAppear {
//            // Start generating career suggestions
//            Task {
//                await viewModel.generateCareerSuggestions()
//                
//                // Once completed, advance to the next step
//                if !viewModel.isLoading {
//                    Task { @MainActor in
//                        await store.advanceToNextStep()
//                    }
//                }
//            }
//        }
//    }
//}
