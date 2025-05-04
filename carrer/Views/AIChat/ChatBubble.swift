import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                Text("AI:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .font(.system(size: 16))
                .foregroundColor(message.isUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser
                        ? Color.blue
                        : (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                )
                .cornerRadius(18)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}