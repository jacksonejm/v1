import Foundation
import SwiftUI
import Combine

// MARK: - OnbDraft Store (Observable, Autosave)

@MainActor
final class OnbDraftStore: ObservableObject {

    // MARK: - Published Properties

    @Published var draft: OnboardingDraft {
        didSet {
            persistDebounced()
        }
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var saveWorkItem: DispatchWorkItem?
    private let storageKey = "mypath.onb.v1.draft"
    private let debounceInterval: TimeInterval = 0.25 // 250ms

    // MARK: - Initialization

    init() {
        // Load existing draft or create new one
        self.draft = Self.loadFromStorage() ?? OnboardingDraft()
    }

    // MARK: - Public Methods

    /// Persists the draft with a debounce delay
    func persistDebounced() {
        // Cancel any pending save
        saveWorkItem?.cancel()

        // Create new work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.persistNow()
        }
        saveWorkItem = workItem

        // Schedule save after debounce interval
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    /// Immediately persists the draft to UserDefaults
    func persistNow() {
        saveWorkItem?.cancel()

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(draft)
            UserDefaults.standard.set(data, forKey: storageKey)

            #if DEBUG
            print("💾 [OnbDraft] Saved to UserDefaults")
            #endif
        } catch {
            print("❌ [OnbDraft] Failed to save: \(error.localizedDescription)")
        }
    }

    /// Loads the draft from UserDefaults
    static func loadFromStorage() -> OnboardingDraft? {
        let storageKey = "mypath.onb.v1.draft"

        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            #if DEBUG
            print("📂 [OnbDraft] No saved draft found")
            #endif
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let draft = try decoder.decode(OnboardingDraft.self, from: data)

            #if DEBUG
            print("✅ [OnbDraft] Loaded from UserDefaults - Last step: \(draft.lastStep.displayName)")
            #endif

            return migrate(draft)
        } catch {
            print("❌ [OnbDraft] Failed to load: \(error.localizedDescription)")
            return nil
        }
    }

    /// Migrates older draft versions to current schema
    private static func migrate(_ draft: OnboardingDraft) -> OnboardingDraft {
        var migrated = draft

        // Schema version 1 is current - no migration needed yet
        if migrated.schemaVersion < 1 {
            migrated.schemaVersion = 1
        }

        return migrated
    }

    /// Clears the saved draft (used when completing onboarding)
    func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        draft = OnboardingDraft()

        #if DEBUG
        print("🗑️ [OnbDraft] Cleared draft from storage")
        #endif
    }

    /// Marks the onboarding as completed
    func markCompleted() {
        draft.completed = true
        persistNow()
    }

    // MARK: - Convenience Methods

    /// Update RIASEC answer for a specific item
    func updateRIASECAnswer(itemId: String, value: Int) {
        draft.answers[itemId] = value
        draft.updatedAt = Date()
    }

    /// Update work value rating
    func updateWorkValue(valueId: String, rating: Int) {
        draft.values[valueId] = rating
        draft.updatedAt = Date()
    }

    /// Toggle subject selection
    func toggleSubject(_ subject: String) {
        if draft.subjects.contains(subject) {
            draft.subjects.removeAll { $0 == subject }
        } else {
            draft.subjects.append(subject)
        }
        draft.updatedAt = Date()
    }

    /// Toggle activity selection
    func toggleActivity(_ activity: String) {
        if draft.activities.contains(activity) {
            draft.activities.removeAll { $0 == activity }
        } else {
            draft.activities.append(activity)
        }
        draft.updatedAt = Date()
    }

    /// Toggle career interest selection
    func toggleInterest(_ interest: String) {
        if draft.interests.contains(interest) {
            draft.interests.removeAll { $0 == interest }
        } else {
            draft.interests.append(interest)
        }
        draft.updatedAt = Date()
    }

    /// Move to next step
    func goToNextStep() {
        if let next = draft.lastStep.next {
            draft.lastStep = next
            draft.updatedAt = Date()
        }
    }

    /// Move to previous step
    func goToPreviousStep() {
        if let previous = draft.lastStep.previous {
            draft.lastStep = previous
            draft.updatedAt = Date()
        }
    }

    /// Jump to specific step
    func goToStep(_ step: OnbStep) {
        draft.lastStep = step
        draft.updatedAt = Date()
    }
}

// MARK: - Scene Phase Handling

extension OnbDraftStore {
    /// Call this from App or View when scene phase changes
    func handleScenePhase(_ phase: ScenePhase) {
        if phase == .background || phase == .inactive {
            persistNow()
        }
    }
}
