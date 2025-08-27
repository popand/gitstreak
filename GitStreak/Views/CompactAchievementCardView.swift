import SwiftUI

struct CompactAchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.title)
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("Unlocked")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .frame(width: 100, height: 80)
        .padding(8)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.4),
                            Color(red: 0.3, green: 0.5, blue: 0.9),
                            Color(red: 0.6, green: 0.3, blue: 0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}