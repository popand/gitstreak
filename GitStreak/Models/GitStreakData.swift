import Foundation

struct CommitData: Identifiable {
    let id = UUID()
    let repo: String
    let message: String
    let time: String
    let commits: Int
}

struct WeeklyData: Identifiable {
    let id = UUID()
    let day: String
    let commits: Int
    let active: Bool
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let unlocked: Bool
}

class GitStreakDataModel: ObservableObject {
    @Published var currentStreak: Int = 7
    @Published var bestStreak: Int = 23
    @Published var level: Int = 12
    @Published var levelTitle: String = "Code Samurai"
    @Published var xp: Int = 2847
    @Published var progress: Double = 0.85
    @Published var xpToNext: Int = 353
    @Published var totalCommitsThisWeek: Int = 21
    
    @Published var recentCommits: [CommitData] = [
        CommitData(repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3),
        CommitData(repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2),
        CommitData(repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1)
    ]
    
    @Published var weeklyData: [WeeklyData] = [
        WeeklyData(day: "Mon", commits: 4, active: true),
        WeeklyData(day: "Tue", commits: 2, active: true),
        WeeklyData(day: "Wed", commits: 6, active: true),
        WeeklyData(day: "Thu", commits: 3, active: true),
        WeeklyData(day: "Fri", commits: 5, active: true),
        WeeklyData(day: "Sat", commits: 1, active: true),
        WeeklyData(day: "Sun", commits: 7, active: true)
    ]
    
    @Published var achievements: [Achievement] = [
        Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: true),
        Achievement(title: "Early Bird", description: "Commit before 9 AM", icon: "🌅", unlocked: true),
        Achievement(title: "Night Owl", description: "Commit after 10 PM", icon: "🦉", unlocked: false)
    ]
}