//import SwiftUI
//
//struct MotivationalMessageView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    
//    // Get name from userData if available
//    private var userName: String {
//        store.value(for: .name) as? String ?? "there"
//    }
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            Image(systemName: "star.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.yellow)
//                .padding()
//                .background(Circle().fill(Color.yellow.opacity(0.2)))
//                .padding(.bottom, 20)
//            
//            Text("You're doing great, \(userName)!")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//            
//            VStack(spacing: 20) {
//                Text("Your journey to finding the perfect career path is well underway.")
//                    .font(.title3)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                Text("The next few questions will help us understand your interests and strengths better.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//            
//            Spacer()
//            
//            Text("Remember, there are no wrong answers! We're here to help you explore what's possible.")
//                .font(.callout)
//                .foregroundColor(.gray)
//                .italic()
//                .multilineTextAlignment(.center)
//                .padding()
//        }
//        .padding()
//    }
//}
