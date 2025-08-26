import SwiftUI

struct AchievementCategoryView: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    let isExpanded: Bool
    let onToggle: () -> Void
    @ObservedObject var dataModel: GitStreakDataModel
    
    private var unlockedCount: Int {
        achievements.filter { $0.unlocked }.count
    }
    
    private var progressPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
    }
    
    private func getVisibleAchievements(for categoryAchievements: [Achievement]) -> [Achievement] {
        var visibleAchievements: [Achievement] = []
        
        // Show unlocked achievements first (limit to 3 max)
        let unlockedAchievements = categoryAchievements.filter { $0.unlocked }
        let displayedUnlocked = Array(unlockedAchievements.prefix(3))
        visibleAchievements.append(contentsOf: displayedUnlocked)
        
        // Calculate remaining slots (max 3 total)
        let remainingSlots = max(0, 3 - displayedUnlocked.count)
        
        // Show next achievable ones based on remaining slots
        if remainingSlots > 0 {
            let lockedAchievements = categoryAchievements.filter { !$0.unlocked }
            let nextAchievements = getNextAchievableAchievements(from: lockedAchievements, category: self.category, maxCount: remainingSlots)
            visibleAchievements.append(contentsOf: nextAchievements)
        }
        
        return visibleAchievements
    }
    
    private func getNextAchievableAchievements(from lockedAchievements: [Achievement], category: AchievementCategory, maxCount: Int) -> [Achievement] {
        // Get current user stats to determine next logical achievements
        let currentStreak = dataModel.currentStreak
        let weeklyCommits = dataModel.totalCommitsThisWeek
        let currentXP = dataModel.xp
        
        // Sort locked achievements by difficulty/requirement to show most achievable first
        let sortedAchievements = lockedAchievements.sorted { first, second in
            // Sort by XP value (assuming lower XP = easier/next logical step)
            AchievementXPHelper.getXP(for: first.title) < AchievementXPHelper.getXP(for: second.title)
        }
        
        // Determine ideal count based on category and user progress, but respect maxCount limit
        let idealCount: Int
        switch category {
        case .streaks:
            idealCount = currentStreak == 0 ? 1 : 2
            
        case .volume:
            idealCount = weeklyCommits < 10 ? 1 : 2
            
        case .dailyPatterns:
            idealCount = 3
            
        case .weeklyPatterns:
            idealCount = 2
            
        case .codeImpact:
            idealCount = currentXP < 500 ? 1 : 2
            
        case .repositoryDiversity:
            idealCount = 2
            
        case .specialMilestones:
            idealCount = currentXP < 1000 ? 1 : 2
        }
        
        let finalCount = min(idealCount, maxCount)
        return Array(sortedAchievements.prefix(finalCount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Header
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Category Icon with Progress Circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: progressPercentage)
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
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 40, height: 40)
                        
                        Text(category.emoji)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("\(unlockedCount)/\(achievements.count) unlocked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Achievement Cards (when expanded) - Only show unlocked + next achievable
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(getVisibleAchievements(for: achievements)) { achievement in
                        SimpleAchievementCardView(achievement: achievement)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct SimpleAchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // Achievement Icon
            Text(achievement.icon)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(achievement.unlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Status Badge
                if achievement.unlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("UNLOCKED")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "lock")
                            .font(.system(size: 10, weight: .bold))
                        Text("LOCKED")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(achievement.unlocked ? Color(.systemBackground) : Color.gray.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    achievement.unlocked ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.4),
                            Color(red: 0.3, green: 0.5, blue: 0.9),
                            Color(red: 0.6, green: 0.3, blue: 0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                    lineWidth: achievement.unlocked ? 2 : 0
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

