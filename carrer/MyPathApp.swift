import SwiftUI
import Firebase
import FirebaseCore

@main
struct MyPathApp: App {
    // Initialize shared instances
    @StateObject private var coordinator = AppCoordinator()
    let persistenceController = PersistenceController.shared
    let networkMonitor = NetworkMonitor.shared
    
    init() {
        FirebaseApp.configure()
        // Set up any other global configurations
        configureAppearance()
    }
    
    private func configureAppearance() {
        // Set up UIKit appearance proxies
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.primary)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(AppColors.primary)]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkMonitor)
                .environmentObject(coordinator)
        }
    }
}