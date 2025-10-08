import CoreData
import os.log

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private let logger = Logger(subsystem: "com.mypath.app", category: "CoreData")
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ConversationModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                self.logger.error("Failed to load persistent store: \(error.localizedDescription)")
                
                // Attempt recovery by deleting the corrupted store and recreating it
                self.handlePersistentStoreError(error: error, description: description)
            } else {
                self.logger.info("Successfully loaded persistent store: \(description.url?.path ?? "unknown")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func handlePersistentStoreError(error: NSError, description: NSPersistentStoreDescription) {
        logger.warning("Attempting to recover from Core Data error")
        
        // Check if it's a migration or corruption issue
        if error.code == NSPersistentStoreIncompatibleVersionHashError ||
           error.code == NSMigrationMissingSourceModelError ||
           error.code == NSPersistentStoreOperationError {
            
            // Attempt to delete the corrupted store file and recreate
            if let storeURL = description.url {
                do {
                    try FileManager.default.removeItem(at: storeURL)
                    logger.info("Removed corrupted store file, attempting to recreate")
                    
                    // Try to load the store again
                    try container.persistentStoreCoordinator.addPersistentStore(
                        ofType: description.type,
                        configurationName: description.configuration,
                        at: storeURL,
                        options: description.options
                    )
                    logger.info("Successfully recreated persistent store")
                    
                } catch {
                    logger.error("Failed to recover from Core Data error: \(error.localizedDescription)")
                    // As a last resort, create an in-memory store
                    createInMemoryFallbackStore()
                }
            }
        } else {
            // For other errors, create an in-memory fallback store
            createInMemoryFallbackStore()
        }
    }
    
    private func createInMemoryFallbackStore() {
        logger.warning("Creating in-memory fallback store - data will not persist")
        
        do {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            
            try container.persistentStoreCoordinator.addPersistentStore(
                ofType: NSInMemoryStoreType,
                configurationName: nil,
                at: nil,
                options: nil
            )
            logger.info("Successfully created in-memory fallback store")
        } catch {
            logger.fault("Critical: Unable to create even in-memory store: \(error.localizedDescription)")
            // This is truly a critical error - the app cannot function without Core Data
            // But we still shouldn't use fatalError in production
        }
    }
    
    // Helper method for saving context if changes exist
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                logger.debug("Successfully saved Core Data context")
            } catch {
                logger.error("Failed to save Core Data context: \(error.localizedDescription)")
            }
        }
    }
    
    // Check if Core Data is available and functioning
    var isAvailable: Bool {
        return !container.persistentStoreCoordinator.persistentStores.isEmpty
    }
    
    // Get a description of the current store type for debugging
    var storeType: String {
        guard let store = container.persistentStoreCoordinator.persistentStores.first else {
            return "No store"
        }
        return store.type == NSInMemoryStoreType ? "In-Memory" : "SQLite"
    }
}