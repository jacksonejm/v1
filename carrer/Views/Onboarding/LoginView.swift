import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text("Welcome back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Sign in to continue your career journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Form fields
            VStack(spacing: 20) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Forgot password
                HStack {
                    Spacer()
                    Button(action: {
                        // Handle forgot password
                    }) {
                        Text("Forgot password?")
                            .font(.subheadline)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            
            // Sign in button
            Button(action: {
                guard !email.isEmpty, !password.isEmpty else {
                    alertMessage = "Please enter your email and password."
                    showingAlert = true
                    return
                }

                viewModel.isLoading = true
                Auth.auth().signIn(withEmail: email, password: password) { _, error in
                    DispatchQueue.main.async {
                        viewModel.isLoading = false

                        if let error = error {
                            alertMessage = error.localizedDescription
                            showingAlert = true
                        } else {
                            viewModel.navigateTo(.dashboard)
                        }
                    }
                }
            }) {
                HStack {
                    Spacer()
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(AppColors.primary)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Or divider
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal)
            
            // Social sign-in options
            HStack(spacing: 20) {
                Button(action: {
                    // Google sign in
                }) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    // Apple sign in
                }) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            // Sign up prompt
            HStack {
                Text("Don't have an account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    isShowingSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.navigateTo(.initial)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}