import Foundation

struct SecureOnboardingCleanupTask {
    static func run(with store: SecureOnboardingStore = .init()) {
        if (try? store.load()) == nil { try? store.delete() }
    }
}
// TODO: scheduling will be wired in a later story