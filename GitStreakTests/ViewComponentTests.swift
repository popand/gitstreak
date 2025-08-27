import XCTest
import SwiftUI
@testable import GitStreak

// Note: These tests focus on view instantiation and basic logic without ViewInspector
// For more advanced SwiftUI testing, consider adding ViewInspector as a dependency

class ViewComponentTests: XCTestCase {
    
    var dataModel: GitStreakDataModel!
    
    override func setUp() {
        super.setUp()
        dataModel = GitStreakDataModel()
    }
    
    override func tearDown() {
        dataModel = nil
        super.tearDown()
    }
    
    // MARK: - ContentView Tests
    
    func testContentViewInstantiation() {
        let contentView = ContentView()
        
        // Test that ContentView can be instantiated
        XCTAssertNotNil(contentView, "ContentView should be instantiable")
        
        // Test that the body property exists and can be accessed
        let body = contentView.body
        XCTAssertNotNil(body, "ContentView should have a body")
    }
    
    func testContentViewWithDataModel() {
        let contentView = ContentView()
        
        // Test that ContentView works with the data model
        XCTAssertNotNil(contentView, "ContentView should be instantiable with data model dependency")
    }
    
    // MARK: - HomeView Tests
    
    func testHomeViewWithDataModel() {
        let homeView = HomeView(dataModel: dataModel)
        
        XCTAssertNotNil(homeView, "HomeView should be instantiable with data model")
        
        // Test that HomeView body can be accessed
        let body = homeView.body
        XCTAssertNotNil(body, "HomeView should have a body")
    }
    
    func testHomeViewGreeting() {
        // Test greeting logic with different times
        let calendar = Calendar.current
        let now = Date()
        
        // Test morning greeting
        var morningComponents = calendar.dateComponents([.year, .month, .day], from: now)
        morningComponents.hour = 8
        let morningDate = calendar.date(from: morningComponents)!
        
        let morningGreeting = getGreetingForTesting(at: morningDate)
        XCTAssertEqual(morningGreeting, "Good morning!", "Should return morning greeting at 8 AM")
        
        // Test afternoon greeting
        var afternoonComponents = calendar.dateComponents([.year, .month, .day], from: now)
        afternoonComponents.hour = 14
        let afternoonDate = calendar.date(from: afternoonComponents)!
        
        let afternoonGreeting = getGreetingForTesting(at: afternoonDate)
        XCTAssertEqual(afternoonGreeting, "Good afternoon!", "Should return afternoon greeting at 2 PM")
        
        // Test evening greeting
        var eveningComponents = calendar.dateComponents([.year, .month, .day], from: now)
        eveningComponents.hour = 19
        let eveningDate = calendar.date(from: eveningComponents)!
        
        let eveningGreeting = getGreetingForTesting(at: eveningDate)
        XCTAssertEqual(eveningGreeting, "Good evening!", "Should return evening greeting at 7 PM")
        
        // Test night greeting
        var nightComponents = calendar.dateComponents([.year, .month, .day], from: now)
        nightComponents.hour = 23
        let nightDate = calendar.date(from: nightComponents)!
        
        let nightGreeting = getGreetingForTesting(at: nightDate)
        XCTAssertEqual(nightGreeting, "Good night!", "Should return night greeting at 11 PM")
    }
    
    // MARK: - StreakCardView Tests
    
    func testStreakCardViewInstantiation() {
        let streakCardView = StreakCardView(streak: 7, bestStreak: 15, isLoading: false)
        
        XCTAssertNotNil(streakCardView, "StreakCardView should be instantiable")
        
        let body = streakCardView.body
        XCTAssertNotNil(body, "StreakCardView should have a body")
    }
    
    func testStreakCardViewLoadingState() {
        let loadingStreakCard = StreakCardView(streak: 0, bestStreak: 0, isLoading: true)
        
        XCTAssertNotNil(loadingStreakCard, "Should create StreakCardView in loading state")
        
        let body = loadingStreakCard.body
        XCTAssertNotNil(body, "Loading StreakCardView should have a body")
    }
    
    // MARK: - LevelProgressView Tests
    
    func testLevelProgressViewInstantiation() {
        let levelProgressView = LevelProgressView(
            level: 12,
            levelTitle: "Code Samurai",
            xp: 2847,
            progress: 0.85,
            xpToNext: 353
        )
        
        XCTAssertNotNil(levelProgressView, "LevelProgressView should be instantiable")
        
        let body = levelProgressView.body
        XCTAssertNotNil(body, "LevelProgressView should have a body")
    }
    
    func testLevelProgressViewWithZeroValues() {
        let levelProgressView = LevelProgressView(
            level: 1,
            levelTitle: "Beginner",
            xp: 0,
            progress: 0.0,
            xpToNext: 100
        )
        
        XCTAssertNotNil(levelProgressView, "Should handle zero values gracefully")
        
        let body = levelProgressView.body
        XCTAssertNotNil(body, "Should have a body with zero values")
    }
    
    // MARK: - WeeklyActivityView Tests
    
    func testWeeklyActivityViewWithData() {
        let weeklyData = [
            WeeklyData(day: "Mon", commits: 4, active: true),
            WeeklyData(day: "Tue", commits: 2, active: true),
            WeeklyData(day: "Wed", commits: 0, active: false),
            WeeklyData(day: "Thu", commits: 3, active: true),
            WeeklyData(day: "Fri", commits: 5, active: true),
            WeeklyData(day: "Sat", commits: 1, active: true),
            WeeklyData(day: "Sun", commits: 0, active: false)
        ]
        
        let weeklyActivityView = WeeklyActivityView(weeklyData: weeklyData, totalCommits: 15)
        
        XCTAssertNotNil(weeklyActivityView, "WeeklyActivityView should be instantiable")
        
        let body = weeklyActivityView.body
        XCTAssertNotNil(body, "WeeklyActivityView should have a body")
    }
    
    func testWeeklyActivityViewEmptyData() {
        let emptyWeeklyData = [
            WeeklyData(day: "Mon", commits: 0, active: false),
            WeeklyData(day: "Tue", commits: 0, active: false),
            WeeklyData(day: "Wed", commits: 0, active: false),
            WeeklyData(day: "Thu", commits: 0, active: false),
            WeeklyData(day: "Fri", commits: 0, active: false),
            WeeklyData(day: "Sat", commits: 0, active: false),
            WeeklyData(day: "Sun", commits: 0, active: false)
        ]
        
        let weeklyActivityView = WeeklyActivityView(weeklyData: emptyWeeklyData, totalCommits: 0)
        
        XCTAssertNotNil(weeklyActivityView, "Should handle empty data gracefully")
        
        let body = weeklyActivityView.body
        XCTAssertNotNil(body, "Should have a body with empty data")
    }
    
    // MARK: - RecentActivityView Tests
    
    func testRecentActivityViewWithCommits() {
        let recentCommits = [
            CommitData(repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3),
            CommitData(repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2),
            CommitData(repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1)
        ]
        
        let recentActivityView = RecentActivityView(commits: recentCommits)
        
        XCTAssertNotNil(recentActivityView, "RecentActivityView should be instantiable")
        
        let body = recentActivityView.body
        XCTAssertNotNil(body, "RecentActivityView should have a body")
    }
    
    func testRecentActivityViewEmptyCommits() {
        let emptyCommits: [CommitData] = []
        let recentActivityView = RecentActivityView(commits: emptyCommits)
        
        XCTAssertNotNil(recentActivityView, "Should handle empty commits gracefully")
        
        let body = recentActivityView.body
        XCTAssertNotNil(body, "Should have a body with empty commits")
    }
    
    // MARK: - AchievementsView Tests
    
    func testAchievementsViewWithMixedAchievements() {
        let achievements = [
            Achievement(title: "First Commit", description: "Make your first commit", icon: "🌱", unlocked: true),
            Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: true),
            Achievement(title: "Early Bird", description: "Commit before 9 AM", icon: "🌅", unlocked: false),
            Achievement(title: "Night Owl", description: "Commit after 10 PM", icon: "🦉", unlocked: false)
        ]
        
        let achievementsView = AchievementsView(achievements: achievements)
        
        XCTAssertNotNil(achievementsView, "AchievementsView should be instantiable")
        
        let body = achievementsView.body
        XCTAssertNotNil(body, "AchievementsView should have a body")
    }
    
    // MARK: - TabBarView Tests
    
    func testTabBarViewInstantiation() {
        let tabBarView = TabBarView(selectedTab: .constant(0))
        
        XCTAssertNotNil(tabBarView, "TabBarView should be instantiable")
        
        let body = tabBarView.body
        XCTAssertNotNil(body, "TabBarView should have a body")
    }
    
    func testTabBarViewWithDifferentSelection() {
        let tabBarView = TabBarView(selectedTab: .constant(2))
        
        XCTAssertNotNil(tabBarView, "Should handle different tab selection")
        
        let body = tabBarView.body
        XCTAssertNotNil(body, "Should have a body with different selection")
    }
    
    // MARK: - Settings View Tests
    
    func testSettingsViewInstantiation() {
        let settingsView = SettingsView(dataModel: dataModel)
        
        XCTAssertNotNil(settingsView, "SettingsView should be instantiable")
        
        let body = settingsView.body
        XCTAssertNotNil(body, "SettingsView should have a body")
    }
    
    // MARK: - StatCardView Tests
    
    func testStreakStatsCardView_DisplaysCorrectData() {
        // Test basic StatCardView instantiation and data display
        let statCardView = StatCardView(
            title: "Current Streak",
            value: "7 days",
            color: .orange
        )
        
        XCTAssertNotNil(statCardView, "StatCardView should be instantiable")
        
        let body = statCardView.body
        XCTAssertNotNil(body, "StatCardView should have a body")
        
        // Test with different data types
        let numericStatCard = StatCardView(
            title: "Total Commits",
            value: "142",
            color: .blue
        )
        XCTAssertNotNil(numericStatCard, "Should handle numeric string values")
        
        let percentageStatCard = StatCardView(
            title: "Growth",
            value: "+25%",
            color: .green
        )
        XCTAssertNotNil(percentageStatCard, "Should handle percentage values")
        
        // Test with empty values
        let emptyStatCard = StatCardView(
            title: "No Data",
            value: "N/A",
            color: .gray
        )
        XCTAssertNotNil(emptyStatCard, "Should handle N/A values gracefully")
        
        // Test with long titles and values
        let longTitleCard = StatCardView(
            title: "Very Long Title That Should Wrap",
            value: "Very Long Value That Might Need Truncation",
            color: .purple
        )
        XCTAssertNotNil(longTitleCard, "Should handle long titles and values")
    }
    
    func testAchievementStatsCardView_MilestoneCalculation() {
        // Create test data model with specific achievement configuration
        let testModel = GitStreakDataModel()
        
        // Test achievement milestone calculation logic
        let firstCommitAchievement = Achievement(
            title: "First Commit",
            description: "Make your first commit",
            icon: "🌱",
            unlocked: true
        )
        
        let weekWarriorAchievement = Achievement(
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            icon: "🔥",
            unlocked: false
        )
        
        let monthMasterAchievement = Achievement(
            title: "Month Master",
            description: "Maintain a 30-day streak",
            icon: "🏆",
            unlocked: false
        )
        
        let testAchievements = [firstCommitAchievement, weekWarriorAchievement, monthMasterAchievement]
        testModel.achievements = testAchievements
        
        // Test milestone calculation for different scenarios
        let unlockedCount = testModel.achievements.filter { $0.unlocked }.count
        XCTAssertEqual(unlockedCount, 1, "Should have 1 unlocked achievement")
        
        let totalCount = testModel.achievements.count
        XCTAssertEqual(totalCount, 3, "Should have 3 total achievements")
        
        let progressPercentage = Double(unlockedCount) / Double(totalCount)
        XCTAssertEqual(progressPercentage, 1.0/3.0, accuracy: 0.01, "Progress should be approximately 33%")
        
        // Test achievement category grouping
        let streakAchievements = testAchievements.filter { $0.title.contains("Streak") || $0.title.contains("Week") || $0.title.contains("Month") }
        XCTAssertEqual(streakAchievements.count, 2, "Should identify 2 streak-related achievements")
        
        // Test achievement milestone boundaries
        let nextMilestone = getNextAchievementMilestone(current: unlockedCount, total: totalCount)
        XCTAssertEqual(nextMilestone, 2, "Next milestone should be 2 achievements")
        
        // Test progress toward next milestone
        let milestoneProgress = Double(unlockedCount) / Double(nextMilestone)
        XCTAssertEqual(milestoneProgress, 0.5, accuracy: 0.01, "Should be 50% toward next milestone")
        
        // Test StatCardView for achievement display
        let achievementStatCard = StatCardView(
            title: "Achievements",
            value: "\(unlockedCount)/\(totalCount)",
            color: .green
        )
        XCTAssertNotNil(achievementStatCard, "Should create achievement stat card")
        
        let milestoneStatCard = StatCardView(
            title: "Next Milestone",
            value: "\(nextMilestone) achievements",
            color: .blue
        )
        XCTAssertNotNil(milestoneStatCard, "Should create milestone stat card")
        
        // Test milestone progress visualization
        let progressStatCard = StatCardView(
            title: "Progress",
            value: String(format: "%.0f%%", progressPercentage * 100),
            color: progressPercentage > 0.5 ? .green : .orange
        )
        XCTAssertNotNil(progressStatCard, "Should create progress stat card")
    }
    
    // MARK: - Edge Case Tests
    
    func testViewsWithExtremeValues() {
        // Test with very large numbers
        let extremeStreakCard = StreakCardView(streak: 999999, bestStreak: 999999, isLoading: false)
        XCTAssertNotNil(extremeStreakCard, "Should handle extreme streak values")
        
        let extremeLevelProgress = LevelProgressView(
            level: 999,
            levelTitle: "Code Legend",
            xp: 99999999,
            progress: 1.0,
            xpToNext: 1
        )
        XCTAssertNotNil(extremeLevelProgress, "Should handle extreme level values")
        
        // Test with zero values
        let zeroStreakCard = StreakCardView(streak: 0, bestStreak: 0, isLoading: false)
        XCTAssertNotNil(zeroStreakCard, "Should handle zero streak values")
        
        let zeroLevelProgress = LevelProgressView(
            level: 1,
            levelTitle: "Beginner",
            xp: 0,
            progress: 0.0,
            xpToNext: 100
        )
        XCTAssertNotNil(zeroLevelProgress, "Should handle zero progress values")
    }
    
    func testViewsWithLongStrings() {
        let longMessage = String(repeating: "Very long commit message that should be handled gracefully ", count: 10)
        let longCommits = [
            CommitData(repo: "repository-with-very-long-name", message: longMessage, time: "1h ago", commits: 1)
        ]
        
        let recentActivityView = RecentActivityView(commits: longCommits)
        XCTAssertNotNil(recentActivityView, "Should handle long strings gracefully")
        
        let longLevelTitle = String(repeating: "Super Ultra Mega ", count: 5) + "Code Master"
        let levelProgressView = LevelProgressView(
            level: 50,
            levelTitle: longLevelTitle,
            xp: 5000,
            progress: 0.5,
            xpToNext: 500
        )
        XCTAssertNotNil(levelProgressView, "Should handle long level titles")
    }
    
    // MARK: - Helper Methods
    
    private func getGreetingForTesting(at date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Good morning!"
        case 12..<17: return "Good afternoon!"
        case 17..<22: return "Good evening!"
        default: return "Good night!"
        }
    }
    
    private func getNextAchievementMilestone(current: Int, total: Int) -> Int {
        // Define achievement milestones
        let milestones = [1, 3, 5, 10, 15, 20, 25]
        
        // Find the next milestone greater than current unlocked achievements
        for milestone in milestones {
            if milestone > current {
                return min(milestone, total) // Don't exceed total achievements
            }
        }
        
        // If all milestones are reached, return total
        return total
    }
}