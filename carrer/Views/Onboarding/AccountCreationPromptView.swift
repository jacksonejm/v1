//import SwiftUI
//import AuthenticationServices
//
//struct AccountCreationPromptView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @State private var showSignUpView = false
//
//    var body: some View {
//        VStack {
//            Spacer()
//            Text("Create an Account")
//                .font(.title)
//                .padding()
//
//            Text("Save your preferences and jumpstart your practice.")
//                .font(.subheadline)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Spacer()
//
//            // Button to show the full-screen sheet
//            Button(action: {
//                showSignUpView = true
//            }) {
//                Text("Continue with Email")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.primaryBlue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal)
//            // Presenting SignUpView as a full-screen sheet
//            .sheet(isPresented: $showSignUpView) {
//                SignUpView(viewModel: viewModel) // Pass the viewModel to the SignUpView
//                    .presentationDetents([.large])
//                    .presentationDragIndicator(.visible)
//            }
//
//            SignInWithAppleButton(
//                onRequest: { request in
//                    // Configure the request
//                },
//                onCompletion: { result in
//                    // Handle the result
//                }
//            )
//            .signInWithAppleButtonStyle(.black)
//            .frame(height: 45)
//            .padding(.horizontal)
//
//            Button(action: {
//                // Handle sign in
//            }) {
//                Text("Sign In")
//                    .font(.subheadline)
//                    .underline()
//                    .padding()
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//}
