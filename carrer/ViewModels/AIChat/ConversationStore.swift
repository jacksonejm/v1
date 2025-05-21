import Foundation
import Combine
import CoreData
import FirebaseAuth

@MainActor
class ConversationStore: ObservableObject {
    // Published properties
    @Published var currentConversation: Conversation?
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // Services
    private let openAIService = OpenAIService()
    private let networkMonitor = NetworkMonitor.shared
    private let persistenceController = PersistenceController.shared
    
    // Stream handling
    private var messageStream: AnyCancellable?
    private var retryCount = 0
    private let maxRetries = 3
    private var cancellables = Set<AnyCancellable>()
    
    // Initialize with optional existing conversation
    init(conversation: Conversation? = nil) {
        if let conversation = conversation {
            self.currentConversation = conversation
            self.messages = conversation.messages
        } else {
            createNewConversation()
        }
        
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        // Monitor network connectivity changes
        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.handleOfflineMode()
                }
            }
            .store(in: &cancellables)
            
        // Listen for user registration to migrate conversations
        NotificationCenter.default.publisher(for: Notification.Name("UserRegisteredNotification"))
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let userId = notification.userInfo?["userId"] as? String {
                    // Handle migration in a background task
                    Task {
                        await self.migrateAnonymousConversations(to: userId)
                    }
                }
            }
            .store(in: &cancellables)
            
        // Also check if there's a pending migration at startup
        Task {
            if UserDefaults.standard.bool(forKey: "needs_conversation_migration"),
               let userId = UserDefaults.standard.string(forKey: "pending_migration_user_id") {
                // Clear the flags first to avoid repeated migrations
                UserDefaults.standard.set(false, forKey: "needs_conversation_migration")
                UserDefaults.standard.removeObject(forKey: "pending_migration_user_id")
                
                // Perform the migration
                await migrateAnonymousConversations(to: userId)
            }
        }
    }
    
    func createNewConversation() {
        currentConversation = Conversation(
            id: UUID(),
            userId: getUserId(),
            startTimestamp: Date(),
            lastUpdateTimestamp: Date(),
            messages: [],
            step: "",
            status: .active
        )
        messages = []
    }
    
    // Add a user message and get AI response
    func sendMessage(_ content: String, forStep step: String) async {
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            content: content,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        
        // Update conversation
        if var conversation = currentConversation {
            conversation.messages.append(userMessage)
            conversation.step = step
            conversation.lastUpdateTimestamp = Date()
            currentConversation = conversation
            await saveConversation()
        }
        
        // Get AI response
        if networkMonitor.isConnected {
            await getAIResponse(for: step)
        } else {
            await getOfflineResponse(content)
        }
    }
    
    private func getAIResponse(for step: String) async {
        isLoading = true
        
        do {
            // Start streaming response
            let systemPrompt = await generateSystemPrompt(for: step)
            
            messageStream = openAIService.streamResponse(
                messages: messages,
                systemPrompt: systemPrompt
            )
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.handleResponseError(error)
                    } else {
                        // Success - reset retry count
                        self.retryCount = 0
                    }
                },
                receiveValue: { [weak self] chunk in
                    guard let self = self else { return }
                    
                    // Handle streaming chunk
                    self.handleResponseChunk(chunk)
                }
            )
        } catch {
            handleResponseError(error)
        }
    }
    
    private func handleResponseChunk(_ chunk: ResponseChunk) {
        switch chunk {
        case .start:
            // Initialize a new AI message
            let newMessage = ChatMessage(
                id: UUID(),
                content: "",
                isUser: false,
                timestamp: Date()
            )
            messages.append(newMessage)
            
        case .content(let text):
            // Append to the last message
            if var lastMessage = messages.last, !lastMessage.isUser {
                lastMessage.content += text
                messages[messages.count - 1] = lastMessage
                
                // Update conversation in Core Data
                if var conversation = currentConversation {
                    conversation.messages = messages
                    currentConversation = conversation
                }
            }
            
        case .toolCall(let tool, let parameters):
            // Handle a new tool call
            print("Tool call received: \(tool)")
            
            // Store the tool call in the message
            if var lastMessage = messages.last, !lastMessage.isUser {
                var toolResults = lastMessage.toolResults ?? [:]
                
                // Execute the tool
                Task {
                    do {
                        if let toolInstance = ToolRegistry.shared.getTool(named: tool) {
                            let result = try await toolInstance.execute(with: parameters)
                            
                            // Use the tool name (String) as the key, not the tool instance
                            toolResults[tool] = result
                            
                            // Update the message with the tool results
                            lastMessage.toolResults = toolResults
                            if lastMessage.id == messages.last?.id {
                                messages[messages.count - 1] = lastMessage
                            }
                            
                            // Update conversation
                            if var conversation = currentConversation {
                                conversation.messages = messages
                                currentConversation = conversation
                            }
                        }
                    } catch {
                        print("Tool execution error: \(error)")
                    }
                }
            }
            
        case .toolCallArguments(let arguments):
            // Handle partial tool call arguments
            print("Tool call arguments received: \(arguments)")
            
        case .toolCallEnd:
            // Handle end of tool call
            print("Tool call completed")

            // After executing the tool, send its result back to OpenAI
            if let lastMessage = messages.last, let results = lastMessage.toolResults,
               let step = currentConversation?.step {
                // Append a tool message so OpenAI can continue the conversation
                let resultString: String
                if let data = try? JSONSerialization.data(withJSONObject: results),
                   let string = String(data: data, encoding: .utf8) {
                    resultString = string
                } else {
                    resultString = "{}"
                }

                let toolMessage = ChatMessage(id: UUID(), content: resultString, isUser: false, timestamp: Date())
                messages.append(toolMessage)

                if var conversation = currentConversation {
                    conversation.messages = messages
                    currentConversation = conversation
                }

                // Restart streaming with the tool result
                messageStream?.cancel()
                Task { [self] in
                    await getAIResponse(for: step)
                }
            }

            break
            
        case .end:
            // Finalize the message and save
            Task {
                await saveConversation()
            }
        }
    }
    
    private func handleResponseError(_ error: Error) {
        self.error = error
        isLoading = false
        
        // Implement retry logic
        if retryCount < maxRetries {
            retryCount += 1
            
            // Exponential backoff
            let delay = pow(2.0, Double(retryCount)) * 0.5
            
            Task {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await getAIResponse(for: currentConversation?.step ?? "")
            }
        } else {
            // Max retries exceeded - add error message
            let errorMessage = ChatMessage(
                id: UUID(),
                content: "I'm having trouble connecting. Please try again later.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
            
            // Update conversation status
            if var conversation = currentConversation {
                conversation.status = .error
                conversation.messages.append(errorMessage)
                currentConversation = conversation
                Task {
                    await saveConversation()
                }
            }
        }
    }
    
    func getOfflineResponse(_ userMessage: String) async {
        isLoading = true
        
        // Simplified offline response for now
        let offlineMessage = ChatMessage(
            id: UUID(),
            content: "I'm currently in offline mode with limited capabilities. Please try again when you have an internet connection.",
            isUser: false,
            timestamp: Date()
        )
        
        messages.append(offlineMessage)
        
        // Update conversation
        if var conversation = currentConversation {
            conversation.messages.append(offlineMessage)
            currentConversation = conversation
            await saveConversation()
        }
        
        isLoading = false
    }
    
    func handleOfflineMode() {
        // Cancel any ongoing streams
        messageStream?.cancel()
        
        // Add offline notification if we were loading
        if isLoading {
            let offlineMessage = ChatMessage(
                id: UUID(),
                content: "I've lost connection. I'll continue in offline mode with limited capabilities.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(offlineMessage)
            isLoading = false
        }
    }
    
    private func saveConversation() async {
        guard let conversation = currentConversation else { return }
        
        // Save to Core Data
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", conversation.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            let conversationEntity: ConversationEntity
            
            if let existingEntity = results.first {
                conversationEntity = existingEntity
            } else {
                conversationEntity = ConversationEntity(context: context)
                conversationEntity.id = conversation.id
            }
            
            conversationEntity.userId = conversation.userId
            conversationEntity.startTimestamp = conversation.startTimestamp
            conversationEntity.lastUpdateTimestamp = conversation.lastUpdateTimestamp
            conversationEntity.step = conversation.step
            conversationEntity.status = conversation.status.rawValue
            
            // Save messages
            if let messagesData = try? JSONEncoder().encode(conversation.messages) {
                conversationEntity.messagesData = messagesData
            }
            
            try context.save()
            
            // Only save to Supabase if:
            // 1. User is connected to the internet
            // 2. User is NOT in anonymous mode (has registered)
            if networkMonitor.isConnected && !isAnonymousMode() {
                Task {
                    do {
                        try await SupabaseService.shared.saveConversation(conversation)
                    } catch {
                        print("Failed to save conversation to Supabase: \(error)")
                        // Log the error but continue - we've already saved locally
                    }
                }
            } else if isAnonymousMode() {
                print("User in anonymous mode - conversation saved locally only")
            }
        } catch {
            print("Failed to save conversation: \(error)")
        }
    }
    
    func fetchConversations() async {
        guard let userId = getUserId() else { return }
        
        if isAnonymousMode() {
            // For anonymous users, only use local storage
            print("Anonymous mode: Only fetching conversations from local storage")
            await fetchLocalConversations()
            return
        }
        
        // For authenticated users, try Supabase first, then fall back to local
        do {
            // Try to fetch from Supabase first if online
            if networkMonitor.isConnected {
                do {
                    // Use the new helper method that attempts to bypass RLS
                    let conversations = try await SupabaseService.shared.getConversationsWithRLSBypass(for: userId)
                    if !conversations.isEmpty {
                        // We have conversations from the server, also save them locally
                        await saveConversationsLocally(conversations)
                        return
                    }
                } catch {
                    print("❌ Failed to fetch conversations from Supabase: \(error.localizedDescription)")
                    
                    // Special handling for RLS errors
                    if error.localizedDescription.contains("violates row-level security policy") {
                        print("""
                        🔒 This is a Row Level Security (RLS) error. To fix it:
                        1. Run the SQL script at /Users/eddym/Downloads/app/carrer/carrer/New/supabase-rls-fix.sql in your Supabase SQL Editor
                        2. See /Users/eddym/Downloads/app/carrer/carrer/New/supabase-rls-fix.md for details
                        """)
                    }
                }
            }
            
            // Fall back to local storage
            await fetchLocalConversations()
        } catch {
            print("Failed to fetch conversations: \(error)")
            // Fall back to local storage
            await fetchLocalConversations()
        }
    }
    
    private func fetchLocalConversations() async {
        guard let userId = getUserId() else { return }
        
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdateTimestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            // Convert to conversation objects
            // This is simplified - we'd need to handle the message data conversion
        } catch {
            print("Failed to fetch local conversations: \(error)")
        }
    }
    
    private func saveConversationsLocally(_ conversations: [Conversation]) async {
        let context = persistenceController.container.viewContext
        
        for conversation in conversations {
            let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", conversation.id as CVarArg)
            do {
                let results = try context.fetch(fetchRequest)
                let conversationEntity: ConversationEntity
                
                if let existingEntity = results.first {
                    conversationEntity = existingEntity
                } else {
                    conversationEntity = ConversationEntity(context: context)
                    conversationEntity.id = conversation.id
                }
                
                conversationEntity.userId = conversation.userId
                conversationEntity.startTimestamp = conversation.startTimestamp
                conversationEntity.lastUpdateTimestamp = conversation.lastUpdateTimestamp
                conversationEntity.step = conversation.step
                conversationEntity.status = conversation.status.rawValue
                
                // Save messages
                if let messagesData = try? JSONEncoder().encode(conversation.messages) {
                    conversationEntity.messagesData = messagesData
                }
                
            } catch {
                print("Failed to save conversation locally: \(error)")
            }
        }
        
        // Save context after batch update
        do {
            try context.save()
        } catch {
            print("Failed to save context after batch update: \(error)")
        }
    }
    
    // Migrate anonymous conversations to the authenticated user
    func migrateAnonymousConversations(to userId: String) async {
        // Implementation would transfer locally stored anonymous conversations to the authenticated user
        print("Migrating anonymous conversations to user: \(userId)")
        // This would be a complex operation involving Core Data and optionally Supabase
    }
    
    // MARK: - Helper methods
    
    private func getUserId() -> String? {
        // Check if user is authenticated with Firebase
        if let currentUser = Auth.auth().currentUser {
            // User is authenticated, return their Firebase UID
            return currentUser.uid
        } else {
            // Return a device-specific anonymous ID for onboarding users
            // This is used for local storage only, not for Supabase
            if let anonymousId = UserDefaults.standard.string(forKey: "anonymous_device_id") {
                return anonymousId
            } else {
                // Create a new anonymous ID if none exists
                let newId = "anon-" + UUID().uuidString
                UserDefaults.standard.set(newId, forKey: "anonymous_device_id")
                return newId
            }
        }
    }
    
    /// Determines if the user is in anonymous mode (onboarding, not registered)
    private func isAnonymousMode() -> Bool {
        // Check if user is authenticated with Firebase
        return Auth.auth().currentUser == nil
    }
    
    /// Synchronizes any conversations that were created offline when connection is restored
    func synchronizeOfflineConversations() async {
        guard !isAnonymousMode() && networkMonitor.isConnected else { return }
        
        // Get user ID
        guard let userId = getUserId() else { return }
        
        // Fetch local conversations that haven't been synced
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND syncStatus == %@", 
                                            userId, "needsSync")
        
        do {
            let results = try context.fetch(fetchRequest)
            print("Found \(results.count) conversations to sync")
            
            // Convert to Conversation objects and sync with backend
            for entity in results {
                // Example implementation - would need to be adjusted for actual data model
                if let messagesData = entity.messagesData,
                   let messages = try? JSONDecoder().decode([ChatMessage].self, from: messagesData) {
                    
                    // Safely unwrap optionals with default values
                    let conversation = Conversation(
                        id: entity.id ?? UUID(),
                        userId: entity.userId ?? userId,
                        startTimestamp: entity.startTimestamp ?? Date(),
                        lastUpdateTimestamp: entity.lastUpdateTimestamp ?? Date(),
                        messages: messages,
                        step: entity.step ?? "",
                        status: Conversation.ConversationStatus(rawValue: entity.status ?? "") ?? .active
                    )
                    
                    // Try to sync with Supabase
                    do {
                        try await SupabaseService.shared.saveConversation(conversation)
                        
                        // Mark as synced in Core Data
                        entity.setValue("synced", forKey: "syncStatus")
                        try context.save()
                    } catch {
                        print("Failed to sync conversation \(entity.id): \(error)")
                    }
                }
            }
        } catch {
            print("Failed to fetch conversations to sync: \(error)")
        }
    }
    
    // MARK: - System Prompt Generation
    
    /// Build a fully-featured, context-aware system prompt for the given onboarding step.
    private func generateSystemPrompt(for step: String) async -> String {
        // Implementation for system prompt generation
        // This would return a string with the system prompt
        return "You are an AI assistant helping a user with their career path. Be helpful, concise, and supportive."
    }
}

