import SwiftUI

struct AIAssistantOverlay: View {
    @ObservedObject var viewModel: AIAssistantViewModel
    @Binding var isPresented: Bool
    let currentStep: OnboardingStep
    @State private var showVoiceAssistant = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Full-screen white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header Bar
                headerBar
                
                Divider()
                    .frame(height: 1)
                    .background(Color.gray.opacity(0.2))
                
                // Message Area
                messageArea
                
                Divider()
                    .frame(height: 1)
                    .background(Color.gray.opacity(0.2))
                
                // Input Row
                inputRow
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // Voice Assistant overlay - shown on top of the AI Assistant
            if showVoiceAssistant {
                VoiceAssistantOverlay(isPresented: $showVoiceAssistant)
                    .transition(.opacity)
                    .zIndex(10) // Ensure it's on top
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showVoiceAssistant)
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            // Title
            Text("MyPath Coach")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Close Button
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Message Area
    private var messageArea: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    // Typing indicator when processing
                    if viewModel.isProcessing {
                        HStack {
                            Spacer(minLength: 70)
                            TypingIndicator()
                                .padding(.vertical, 8)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color.white)
            }
        }
    }

    
    // MARK: - Input Row
    private var inputRow: some View {
        HStack(spacing: 12) {
            // Voice Button
            Button(action: {
                viewModel.toggleVoiceMode()
                // Show voice assistant on top of this view
                withAnimation {
                    showVoiceAssistant = true
                }
            }) {
                Image(systemName: "mic.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .padding(10)
            }
            
            // Text Field
            TextField("Type a message...", text: $viewModel.inputText)
                .font(.system(size: 16))
                .padding(.vertical, 8)
                .foregroundColor(.primary)
            
            // Send Button
            Button(action: {
              Task {
                await viewModel.sendMessage()
              }
            }) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    )
            }
            .disabled(viewModel.inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}