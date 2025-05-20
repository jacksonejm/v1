import Foundation

func migrateOnboardingIfNeeded(legacy: UserDefaults = .standard,
                              store: SecureOnboardingStore = .init()) {
    guard let first = legacy.string(forKey: "onb_firstName") else { return }
    let dto = OnboardingDTO(
        firstName: first,
        lastName: legacy.string(forKey: "onb_lastName") ?? "",
        birthDate: legacy.object(forKey:"onb_birthDate") as? Date ?? Date(),
        progressStep: legacy.integer(forKey: "onb_progressStep"))
    try? store.save(dto)
    ["onb_firstName","onb_lastName","onb_birthDate","onb_progressStep"].forEach { legacy.removeObject(forKey:$0) }
}