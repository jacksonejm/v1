import SwiftUI
import Combine

/// Manages the onboarding mode selection and transitions
@MainActor
class OnboardingModeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentMode: OnboardingMode = .unselected
    @Published var isTransitioning: Bool = false
    @Published var showModeSelection: Bool = true
    
    // MARK: - Private Properties
    private let onboardingStore: OnboardingStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var canSwitchModes: Bool {
        !isTransitioning && currentMode != .unselected
    }
    
    var hasSelectedMode: Bool {
        currentMode != .unselected
    }
    
    // MARK: - Initialization
    init(onboardingStore: OnboardingStore) {
        self.onboardingStore = onboardingStore
        setupBindings()
        checkExistingProgress()
    }
    
    // MARK: - Public Methods
    
    /// Select and start the specified onboarding mode
    func selectMode(_ mode: OnboardingMode) {
        guard mode != .unselected else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMode = mode
            showModeSelection = false
        }
        
        // Store the selected mode
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedOnboardingMode")
        
        // Log analytics
        logModeSelection(mode)
    }
    
    /// Switch from one mode to another with data preservation
    func switchMode(to newMode: OnboardingMode, preserveData: Bool = true) async {
        guard canSwitchModes && newMode != currentMode && newMode != .unselected else { return }
        
        isTransitioning = true
        
        if preserveData {
            // Save current progress before switching
            await saveCurrentProgress()
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMode = newMode
        }
        
        // Update stored preference
        UserDefaults.standard.set(newMode.rawValue, forKey: "selectedOnboardingMode")
        
        isTransitioning = false
        
        // Log analytics
        logModeSwitch(from: currentMode, to: newMode)
    }
    
    /// Reset to mode selection
    func resetToModeSelection() {
        withAnimation {
            currentMode = .unselected
            showModeSelection = true
        }
        UserDefaults.standard.removeObject(forKey: "selectedOnboardingMode")
    }
    
    /// Get the current onboarding progress
    func getCurrentProgress() -> OnboardingProgress {
        // Calculate completed fields based on values that have been set
        let completedFields = Set(onboardingStore.values.keys)
        
        // Estimate total fields (this would ideally come from StepFieldSpec)
        let totalFields = OnboardingField.allCases.count
        
        return OnboardingProgress(
            mode: currentMode,
            completedFields: completedFields,
            totalFields: totalFields,
            currentStep: onboardingStore.currentStep
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor onboarding step changes to detect completion
        onboardingStore.$currentStep
            .sink { [weak self] currentStep in
                if case .completionScreen = currentStep {
                    self?.handleOnboardingCompletion()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkExistingProgress() {
        // Check if user has previously selected a mode
        if let savedMode = UserDefaults.standard.string(forKey: "selectedOnboardingMode"),
           let mode = OnboardingMode(rawValue: savedMode),
           mode != .unselected {
            
            // Check if onboarding is already complete
            if case .completionScreen = onboardingStore.currentStep {
                // Onboarding is complete, don't restore mode
            } else {
                currentMode = mode
                showModeSelection = false
            }
        }
        
        // Check if there's existing progress in traditional mode
        let hasProgress = !onboardingStore.values.isEmpty
        if hasProgress && currentMode == .unselected {
            // User has started traditional onboarding before mode selection was introduced
            currentMode = .traditional
            showModeSelection = false
        }
    }
    
    private func saveCurrentProgress() async {
        // This will be used when switching modes to preserve data
        // The actual implementation will depend on the data bridge (Week 8)
        print("Saving current progress for mode: \(currentMode)")
    }
    
    private func handleOnboardingCompletion() {
        // Clean up mode selection preference after completion
        UserDefaults.standard.removeObject(forKey: "selectedOnboardingMode")
    }
    
    // MARK: - Analytics
    
    private func logModeSelection(_ mode: OnboardingMode) {
        print("Analytics: User selected onboarding mode: \(mode.rawValue)")
        // TODO: Integrate with actual analytics service
    }
    
    private func logModeSwitch(from oldMode: OnboardingMode, to newMode: OnboardingMode) {
        print("Analytics: User switched from \(oldMode.rawValue) to \(newMode.rawValue)")
        // TODO: Integrate with actual analytics service
    }
}

// MARK: - Supporting Types

struct OnboardingProgress {
    let mode: OnboardingMode
    let completedFields: Set<OnboardingField>
    let totalFields: Int
    let currentStep: OnboardingStep?
    
    var percentComplete: Double {
        guard totalFields > 0 else { return 0 }
        return Double(completedFields.count) / Double(totalFields)
    }
    
    var isComplete: Bool {
        completedFields.count >= totalFields
    }
}