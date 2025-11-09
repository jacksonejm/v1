import SwiftUI

struct VoiceAssistantOverlay: View {
    @Binding var isPresented: Bool
    @State private var isListening = false
    @State private var animationScale: CGFloat = 1.0
    @State private var transcribedText = ""
    @State private var recognitionState: RecognitionState = .inactive
    
    enum RecognitionState {
        case inactive
        case listening
        case processing
        case result
        case error
    }
    
    var body: some View {
        ZStack {
            // Full-screen semi-opaque backdrop
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Header
                Text("Voice Assistant")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Visualization and status
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    // Animated circle
                    Circle()
                        .fill(AppColors.primary.opacity(isListening ? 0.3 : 0.0))
                        .frame(width: 180 * animationScale, height: 180 * animationScale)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: animationScale
                        )
                    
                    // Mic icon
                    Image(systemName: recognitionState == .listening ? "waveform" : "mic.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    toggleListening()
                }
                
                // Status text
                Text(statusText)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Transcription result (when available)
                if !transcribedText.isEmpty && recognitionState == .result {
                    Text(transcribedText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 40) {
                    // Cancel button
                    Button(action: {
                        isPresented = false
                    }) {
                        VStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                            Text("Cancel")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                    }
                    
                    // Listen button (only when not already listening)
                    if recognitionState != .listening {
                        Button(action: {
                            toggleListening()
                        }) {
                            VStack {
                                Image(systemName: recognitionState == .result ? "arrow.right.circle.fill" : "mic.circle.fill")
                                    .font(.system(size: 48))
                                Text(recognitionState == .result ? "Submit" : "Listen")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    // Help button
                    Button(action: {
                        // Show help about voice assistant
                    }) {
                        VStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 32))
                            Text("Help")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            // Start animation
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                animationScale = 1.2
            }
        }
    }
    
    // Status text based on current state
    private var statusText: String {
        switch recognitionState {
        case .inactive:
            return "Tap the microphone to start speaking"
        case .listening:
            return "I'm listening... Tap again when you're done"
        case .processing:
            return "Processing your request..."
        case .result:
            return "Is this what you said?"
        case .error:
            return "Sorry, I didn't catch that. Please try again."
        }
    }
    
    // Toggle listening state
    private func toggleListening() {
        if recognitionState == .listening {
            // Stop listening
            recognitionState = .processing
            isListening = false
            
            // Simulate processing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if transcribedText.isEmpty {
                    transcribedText = "Show me career recommendations for software developers"
                }
                recognitionState = .result
            }
        } else if recognitionState == .result {
            // Process the transcribed text
            processVoiceCommand(transcribedText)
            
            // Use a small delay to avoid state updates during view updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPresented = false
            }
        } else {
            // Start listening
            recognitionState = .listening
            isListening = true
            transcribedText = ""
            
            // In a real app, this would trigger speech recognition
            // For this demo, we'll simulate recognition after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if recognitionState == .listening {
                    recognitionState = .processing
                    isListening = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        transcribedText = "Show me career recommendations for software developers"
                        recognitionState = .result
                    }
                }
            }
        }
    }
    
    // Process the voice command
    private func processVoiceCommand(_ command: String) {
        // In a real app, this would send the command to a handler
        print("Processing voice command: \(command)")
    }
}