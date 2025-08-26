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

struct AchievementSummaryView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    private var totalAchievements: Int {
        dataModel.achievements.count
    }
    
    private var nextMilestone: String {
        let unlocked = dataModel.unlockedAchievementCount
        let nextTargets = [10, 25, 50, 75, 100]
        
        for target in nextTargets {
            if unlocked < target {
                return "Achievement Hunter (\(target) total)"
            }
        }
        return "All achievements unlocked!"
    }
    
    private var milestoneProgress: Double {
        let unlocked = dataModel.unlockedAchievementCount
        let nextTargets = [10, 25, 50, 75, 100]
        
        for target in nextTargets {
            if unlocked < target {
                return Double(unlocked) / Double(target)
            }
        }
        return 1.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Achievement Progress")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Total Achievements
                StatCardView(
                    title: "Achievements",
                    value: "\(dataModel.unlockedAchievementCount)/\(totalAchievements)",
                    color: .green
                )
                
                // Achievement XP
                StatCardView(
                    title: "Bonus XP",
                    value: "\(dataModel.totalAchievementXP.formatted())",
                    color: .blue
                )
            }
            
            // Next Milestone Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Next Milestone")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(nextMilestone)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                ProgressBarView(progress: milestoneProgress, height: 6)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementCategoryView: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    let isExpanded: Bool
    let onToggle: () -> Void
    
    private var unlockedCount: Int {
        achievements.filter { $0.unlocked }.count
    }
    
    private var progressPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
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
            
            // Achievement Cards (when expanded)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(achievements) { achievement in
                        SimpleAchievementCardView(achievement: achievement)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct ProgressBarView: View {
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(progress: Double, height: CGFloat = 8, cornerRadius: CGFloat? = nil) {
        self.progress = progress
        self.height = height
        self.cornerRadius = cornerRadius ?? height / 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.8, blue: 0.4),
                                Color(red: 0.3, green: 0.5, blue: 0.9),
                                Color(red: 0.6, green: 0.3, blue: 0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
            }
        }
        .frame(height: height)
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