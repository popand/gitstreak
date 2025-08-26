import SwiftUI

struct AchievementsView: View {
    let achievements: [Achievement]
    
    private func getAchievementXP(for title: String) -> Int {
        // Map achievement titles to their XP values
        let xpValues: [String: Int] = [
            // Common achievements displayed on Home screen
            "First Commit": 25,
            "First Flame": 25,
            "Week Warrior": 100,
            "Early Bird": 75,
            "Night Owl": 75,
            "Getting Warmed Up": 50,
            "Fortnight Fighter": 200,
            "Monthly Master": 350,
            "First Steps": 25,
            "Getting Started": 50,
            "Century Club": 100
        ]
        return xpValues[title] ?? 100
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(achievements) { achievement in
                HStack(spacing: 12) {
                    Text(achievement.icon)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(achievement.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(achievement.unlocked ? .primary : .secondary)
                            
                            // XP Badge
                            Text("\(getAchievementXP(for: achievement.title)) XP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(achievement.unlocked ? .blue : .gray)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(achievement.unlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
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