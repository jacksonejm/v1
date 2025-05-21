import Foundation

class UpdateFieldTool: AITool {
    let name = "update_onboarding_field"
    let description = "Update a field in the onboarding flow"
    private unowned let onboardingStore: OnboardingStore

    init(onboardingStore: OnboardingStore) {
        self.onboardingStore = onboardingStore
    }

    func execute(with parameters: [String : Any]) async throws -> Any {
        guard let fieldName = parameters["field"] as? String,
              let value = parameters["value"],
              let field = OnboardingField(rawValue: fieldName) else {
            throw ToolError.invalidParameters(message: "field and value required")
        }

        let confidence = (parameters["confidence"] as? Double).map { Float($0) } ?? 1.0
        await MainActor.run {
            self.onboardingStore.aiWrite(field: field, value: value, confidence: confidence)
        }
        return ["status": "ok"]
    }
}
