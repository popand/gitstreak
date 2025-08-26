import SwiftUI

struct AchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(achievements) { achievement in
                HStack(spacing: 12) {
                    Text(achievement.icon)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(achievement.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(achievement.unlocked ? .primary : .secondary)
                        
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if achievement.unlocked {
                        Text("Unlocked")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(achievement.unlocked ? Color(.systemBackground) : Color.gray.opacity(0.05))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
}