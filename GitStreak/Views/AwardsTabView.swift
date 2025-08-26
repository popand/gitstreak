import SwiftUI

struct AwardsTabView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    @State private var expandedCategories: Set<AchievementCategory> = []
    
    private var achievementsByCategory: [AchievementCategory: [Achievement]] {
        Dictionary(grouping: dataModel.achievements, by: { $0.category })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Summary Stats
                AchievementSummaryView(dataModel: dataModel)
                
                // Achievement Categories
                VStack(spacing: 16) {
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        AchievementCategoryView(
                            category: category,
                            achievements: achievementsByCategory[category] ?? [],
                            isExpanded: expandedCategories.contains(category),
                            onToggle: {
                                if expandedCategories.contains(category) {
                                    expandedCategories.remove(category)
                                } else {
                                    expandedCategories.insert(category)
                                }
                            },
                            dataModel: dataModel
                        )
                    }
                }
                
                // Recent Achievements
                if !dataModel.recentlyUnlockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Achievements")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(dataModel.recentlyUnlockedAchievements.prefix(5)) { achievement in
                                    CompactAchievementCardView(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .navigationTitle("Awards")
        .background(Color(.systemGroupedBackground))
    }
}

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