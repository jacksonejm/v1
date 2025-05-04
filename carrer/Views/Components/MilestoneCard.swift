import SwiftUI

// Add missing model imports
import Foundation

struct MilestoneCard: View {
    let milestone: Milestone
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: statusIcon)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title)
                        .font(.headline)
                    
                    Text(milestone.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Progress Label
                Text("\(milestone.progress)%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(milestone.progress) / 100, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            // Action Button
            Button(action: {
                // Handle action
            }) {
                Text(milestone.actionTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(actionButtonColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var statusIcon: String {
        switch milestone.status {
        case .completed:
            return "checkmark.circle.fill"
        case .inProgress:
            return "clock.fill"
        case .pending:
            return "circle"
        }
    }
    
    private var backgroundColor: Color {
        switch milestone.status {
        case .completed:
            return Color.green.opacity(0.1)
        case .inProgress:
            return Color.blue.opacity(0.1)
        case .pending:
            return Color.gray.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
    
    private var progressColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
    
    private var actionButtonColor: Color {
        switch milestone.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
}