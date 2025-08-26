import SwiftUI

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