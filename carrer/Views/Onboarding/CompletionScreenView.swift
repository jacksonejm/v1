//import SwiftUI
//
//struct CompletionScreenView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var showAccountCreationPrompt = false
//    
//    // Get name from the store
//    private var userName: String {
//        store.value(for: .name) as? String ?? "there"
//    }
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            // Success icon
//            Image(systemName: "checkmark.circle.fill")
//                .font(.system(size: 100))
//                .foregroundColor(AppColors.primary)
//                .padding(.bottom, 20)
//            
//            Text("Congratulations, \(userName)!")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            Text("Your career profile is complete")
//                .font(.title2)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            VStack(spacing: 15) {
//                Text("We've analyzed your responses and created personalized career recommendations just for you.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
//                
//                Text("Create an account to save your results and unlock all features.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 10)
//            }
//            
//            Spacer()
//            
//            // Account creation button (handled in OnboardingView)
//            // Use the 'Next' button in OnboardingView which will show the account creation prompt
//        }
//        .padding()
//    }
//}
