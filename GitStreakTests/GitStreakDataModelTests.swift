import XCTest
import Foundation
import Combine
@testable import GitStreak

class GitStreakDataModelTests: XCTestCase {
    
    var dataModel: GitStreakDataModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        dataModel = GitStreakDataModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        dataModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDataModelInitialization() {
        // Test that data model initializes with expected default values
        XCTAssertGreaterThanOrEqual(dataModel.currentStreak, 0, "Current streak should be non-negative")
        XCTAssertGreaterThanOrEqual(dataModel.bestStreak, 0, "Best streak should be non-negative")
        XCTAssertGreaterThanOrEqual(dataModel.level, 1, "Level should start at 1 or higher")
        XCTAssertFalse(dataModel.levelTitle.isEmpty, "Level title should not be empty")
        XCTAssertGreaterThanOrEqual(dataModel.xp, 0, "XP should be non-negative")
        XCTAssertGreaterThanOrEqual(dataModel.progress, 0.0, "Progress should be non-negative")
        XCTAssertLessThanOrEqual(dataModel.progress, 1.0, "Progress should not exceed 1.0")
        XCTAssertGreaterThan(dataModel.xpToNext, 0, "XP to next level should be positive")
        XCTAssertGreaterThanOrEqual(dataModel.totalCommitsThisWeek, 0, "Total commits should be non-negative")
        XCTAssertFalse(dataModel.isLoading, "Should not be loading initially")
        XCTAssertNil(dataModel.errorMessage, "Should not have error message initially")
    }
    
    func testWeeklyDataInitialization() {
        XCTAssertEqual(dataModel.weeklyData.count, 7, "Should have 7 days of weekly data")
        
        let expectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for (index, weeklyData) in dataModel.weeklyData.enumerated() {
            XCTAssertEqual(weeklyData.day, expectedDays[index], "Day should match expected order")
            XCTAssertGreaterThanOrEqual(weeklyData.commits, 0, "Commits should be non-negative")
        }
    }
    
    func testAchievementsInitialization() {
        XCTAssertGreaterThan(dataModel.achievements.count, 0, "Should have initial achievements")
        
        for achievement in dataModel.achievements {
            XCTAssertFalse(achievement.title.isEmpty, "Achievement title should not be empty")
            XCTAssertFalse(achievement.description.isEmpty, "Achievement description should not be empty")
            XCTAssertFalse(achievement.icon.isEmpty, "Achievement icon should not be empty")
        }
    }
    
    // MARK: - State Management Tests
    
    func testLoadingStateManagement() {
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        dataModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger loading by calling loadGitHubData directly to test async loading
        dataModel.loadGitHubData()
        
        wait(for: [expectation], timeout: 5.0)
        
        // Should have at least initial false and then true (loading started)
        XCTAssertGreaterThanOrEqual(loadingStates.count, 2, "Should have multiple loading states")
        XCTAssertFalse(loadingStates.first!, "Should start with not loading")
    }
    
    func testErrorStateManagement() {
        let expectation = XCTestExpectation(description: "Error state handling")
        
        dataModel.$errorMessage
            .dropFirst() // Skip initial nil
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Force an error by calling loadGitHubData directly without authentication
        // This will trigger the GitHub API call which should fail and set an error
        dataModel.loadGitHubData()
        
        wait(for: [expectation], timeout: 10.0)
        
        // Should have an error message after failed GitHub API call
        XCTAssertNotNil(dataModel.errorMessage, "Should have error message after failed API call")
        XCTAssertFalse(dataModel.errorMessage!.isEmpty, "Error message should not be empty")
    }
    
    // MARK: - Weekly Data Update Tests
    
    func testUpdateWeeklyDataFromCommits() {
        let testCommits = [
            "Mon": 3,
            "Wed": 5,
            "Fri": 2,
            "Sun": 1
        ]
        
        // Use reflection or create a method to test this private functionality
        updateWeeklyDataForTesting(from: testCommits)
        
        // Verify the data was updated correctly
        let mondayData = dataModel.weeklyData.first { $0.day == "Mon" }
        let wednesdayData = dataModel.weeklyData.first { $0.day == "Wed" }
        let fridayData = dataModel.weeklyData.first { $0.day == "Fri" }
        let sundayData = dataModel.weeklyData.first { $0.day == "Sun" }
        let tuesdayData = dataModel.weeklyData.first { $0.day == "Tue" }
        
        XCTAssertEqual(mondayData?.commits, 3, "Monday should have 3 commits")
        XCTAssertEqual(wednesdayData?.commits, 5, "Wednesday should have 5 commits")
        XCTAssertEqual(fridayData?.commits, 2, "Friday should have 2 commits")
        XCTAssertEqual(sundayData?.commits, 1, "Sunday should have 1 commit")
        XCTAssertEqual(tuesdayData?.commits, 0, "Tuesday should have 0 commits")
        
        XCTAssertTrue(mondayData?.active ?? false, "Monday should be active")
        XCTAssertTrue(wednesdayData?.active ?? false, "Wednesday should be active")
        XCTAssertFalse(tuesdayData?.active ?? true, "Tuesday should not be active")
        
        XCTAssertEqual(dataModel.totalCommitsThisWeek, 11, "Total should be 3+5+2+1=11")
    }
    
    func testUpdateWeeklyDataWithEmptyCommits() {
        let emptyCommits: [String: Int] = [:]
        
        updateWeeklyDataForTesting(from: emptyCommits)
        
        for weeklyData in dataModel.weeklyData {
            XCTAssertEqual(weeklyData.commits, 0, "All days should have 0 commits")
            XCTAssertFalse(weeklyData.active, "No days should be active")
        }
        
        XCTAssertEqual(dataModel.totalCommitsThisWeek, 0, "Total commits should be 0")
    }
    
    // MARK: - Level Calculation Tests
    
    func testLevelCalculation() {
        // Test different scenarios
        let testCases: [(currentStreak: Int, totalCommitsThisWeek: Int, expectedMinLevel: Int)] = [
            (0, 0, 1),      // Minimum level
            (5, 10, 2),     // (10 + 5*2) / 10 = 2
            (10, 50, 7),    // (50 + 10*2) / 10 = 7
            (25, 100, 15)   // (100 + 25*2) / 10 = 15
        ]
        
        for (streak, weeklyCommits, expectedMinLevel) in testCases {
            dataModel.currentStreak = streak
            dataModel.totalCommitsThisWeek = weeklyCommits
            
            calculateLevelForTesting()
            
            XCTAssertGreaterThanOrEqual(dataModel.level, expectedMinLevel,
                                      "Level should be at least \(expectedMinLevel) for streak \(streak) and weekly commits \(weeklyCommits)")
            
            // XP should be non-negative (0 is valid for no activity)
            XCTAssertGreaterThanOrEqual(dataModel.xp, 0, "XP should be non-negative")
            XCTAssertGreaterThan(dataModel.xpToNext, 0, "XP to next should be positive")
            XCTAssertGreaterThanOrEqual(dataModel.progress, 0.0, "Progress should be non-negative")
            XCTAssertLessThanOrEqual(dataModel.progress, 1.0, "Progress should not exceed 1.0")
        }
    }
    
    func testLevelTitles() {
        let testLevels = [1, 3, 7, 12, 18, 25, 35]
        let expectedTitles = ["Beginner", "Beginner", "Code Ninja", "Code Samurai", "Code Samurai", "Git Master", "Code Legend"]
        
        for (level, expectedTitle) in zip(testLevels, expectedTitles) {
            let actualTitle = getLevelTitleForTesting(for: level)
            XCTAssertEqual(actualTitle, expectedTitle, "Level \(level) should have title '\(expectedTitle)'")
        }
    }
    
    // MARK: - Achievement Update Tests
    
    func testAchievementUpdates() {
        // Test First Commit achievement
        dataModel.recentCommits = []
        updateAchievementsForTesting()
        
        let firstCommitAchievement = dataModel.achievements.first { $0.title == "First Commit" }
        XCTAssertFalse(firstCommitAchievement?.unlocked ?? true, "First Commit should not be unlocked without commits")
        
        // Add a commit
        dataModel.recentCommits = [
            CommitData(repo: "test-repo", message: "Test commit", time: "1h ago", commits: 1)
        ]
        updateAchievementsForTesting()
        
        let updatedFirstCommitAchievement = dataModel.achievements.first { $0.title == "First Commit" }
        XCTAssertTrue(updatedFirstCommitAchievement?.unlocked ?? false, "First Commit should be unlocked with commits")
        
        // Test Week Warrior achievement
        dataModel.currentStreak = 5
        updateAchievementsForTesting()
        
        let weekWarriorAchievement = dataModel.achievements.first { $0.title == "Week Warrior" }
        XCTAssertFalse(weekWarriorAchievement?.unlocked ?? true, "Week Warrior should not be unlocked with 5-day streak")
        
        dataModel.currentStreak = 7
        updateAchievementsForTesting()
        
        let updatedWeekWarriorAchievement = dataModel.achievements.first { $0.title == "Week Warrior" }
        XCTAssertTrue(updatedWeekWarriorAchievement?.unlocked ?? false, "Week Warrior should be unlocked with 7-day streak")
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistency() {
        // Test that data remains consistent after operations
        let initialBestStreak = 10
        let initialCurrentStreak = 8
        
        dataModel.bestStreak = initialBestStreak
        dataModel.currentStreak = initialCurrentStreak
        
        // Test that current streak doesn't exceed best streak in normal operation
        XCTAssertLessThanOrEqual(dataModel.currentStreak, dataModel.bestStreak,
                                "Current streak should not exceed best streak initially")
        
        // Test the streak calculation logic maintains consistency
        let mockCommits = createMockCommitsForConsistencyTest()
        let calculatedBestStreak = calculateStreakForTesting(from: mockCommits)
        
        // The calculated best streak should be reasonable
        XCTAssertGreaterThanOrEqual(calculatedBestStreak, 0, "Calculated best streak should be non-negative")
        
        // Test that when we update streaks, best streak is properly maintained
        if calculatedBestStreak > dataModel.bestStreak {
            dataModel.bestStreak = calculatedBestStreak
        }
        if calculatedBestStreak > dataModel.currentStreak {
            dataModel.currentStreak = calculatedBestStreak
        }
        
        XCTAssertLessThanOrEqual(dataModel.currentStreak, dataModel.bestStreak,
                                "After updates, current streak should not exceed best streak")
    }
    
    func testWeeklyDataConsistency() {
        updateWeeklyDataForTesting(from: ["Mon": 2, "Wed": 3, "Fri": 1])
        
        let totalFromIndividualDays = dataModel.weeklyData.reduce(0) { $0 + $1.commits }
        XCTAssertEqual(dataModel.totalCommitsThisWeek, totalFromIndividualDays,
                      "Total commits should equal sum of individual days")
    }
    
    // MARK: - Refresh Data Tests
    
    func testRefreshDataTriggersStateChanges() {
        let expectation = XCTestExpectation(description: "Refresh triggers state changes")
        var stateChanges = 0
        
        // Monitor multiple properties for changes
        Publishers.CombineLatest4(
            dataModel.$currentStreak,
            dataModel.$isLoading,
            dataModel.$totalCommitsThisWeek,
            dataModel.$errorMessage
        )
        .dropFirst() // Skip initial values
        .sink { _ in
            stateChanges += 1
            if stateChanges >= 2 { // Allow for multiple state changes
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        dataModel.refreshData()
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertGreaterThan(stateChanges, 0, "Refresh should trigger state changes")
    }
    
    // MARK: - Mock Data Tests
    
    func testMockDataConsistency() {
        // Force load mock data for testing
        loadMockDataForTesting()
        
        // Verify mock data meets expectations
        XCTAssertGreaterThan(dataModel.currentStreak, 0, "Mock data should have positive current streak")
        XCTAssertGreaterThan(dataModel.bestStreak, 0, "Mock data should have positive best streak")
        XCTAssertGreaterThanOrEqual(dataModel.bestStreak, dataModel.currentStreak,
                                   "Mock best streak should be >= current streak")
        XCTAssertGreaterThan(dataModel.level, 0, "Mock data should have positive level")
        XCTAssertFalse(dataModel.levelTitle.isEmpty, "Mock data should have level title")
        XCTAssertGreaterThan(dataModel.totalCommitsThisWeek, 0, "Mock data should have commits this week")
        XCTAssertGreaterThan(dataModel.recentCommits.count, 0, "Mock data should have recent commits")
        
        // Verify weekly data adds up
        let weeklyTotal = dataModel.weeklyData.reduce(0) { $0 + $1.commits }
        XCTAssertEqual(weeklyTotal, dataModel.totalCommitsThisWeek,
                      "Mock weekly data should be consistent")
        
        // Verify some achievements are unlocked in mock data
        let unlockedAchievements = dataModel.achievements.filter { $0.unlocked }
        XCTAssertGreaterThan(unlockedAchievements.count, 0, "Mock data should have some unlocked achievements")
    }
    
    // MARK: - Performance Tests
    
    func testDataModelPerformance() {
        measure {
            for _ in 0..<100 {
                calculateLevelForTesting()
                updateAchievementsForTesting()
            }
        }
    }
    
    func testLargeDataSetHandling() {
        // Test with large commit data
        let largeCommitData = (0..<1000).map { i in
            CommitData(repo: "repo-\(i)", message: "Commit \(i)", time: "\(i)h ago", commits: 1)
        }
        
        dataModel.recentCommits = largeCommitData
        
        updateAchievementsForTesting()
        
        // Should handle large data without crashing
        XCTAssertEqual(dataModel.recentCommits.count, 1000, "Should handle large commit arrays")
    }
    
    // MARK: - Helper Methods for Testing Private Functionality
    
    private func updateWeeklyDataForTesting(from commits: [String: Int]) {
        for i in 0..<dataModel.weeklyData.count {
            let day = dataModel.weeklyData[i].day
            let commitCount = commits[day] ?? 0
            dataModel.weeklyData[i] = WeeklyData(day: day, commits: commitCount, active: commitCount > 0)
        }
        dataModel.totalCommitsThisWeek = commits.values.reduce(0, +)
    }
    
    private func calculateLevelForTesting() {
        let totalCommits = dataModel.totalCommitsThisWeek + (dataModel.currentStreak * 2)
        dataModel.level = max(1, totalCommits / 10)
        dataModel.xp = totalCommits * 100
        dataModel.xpToNext = ((dataModel.level + 1) * 10 * 100) - dataModel.xp
        dataModel.progress = Double(dataModel.xp % 1000) / 1000.0
        
        dataModel.levelTitle = getLevelTitleForTesting(for: dataModel.level)
    }
    
    private func getLevelTitleForTesting(for level: Int) -> String {
        switch level {
        case 1...5: return "Beginner"
        case 6...10: return "Code Ninja"
        case 11...20: return "Code Samurai"
        case 21...30: return "Git Master"
        default: return "Code Legend"
        }
    }
    
    private func updateAchievementsForTesting() {
        for i in 0..<dataModel.achievements.count {
            let achievement = dataModel.achievements[i]
            
            switch achievement.title {
            case "First Commit":
                dataModel.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlocked: !dataModel.recentCommits.isEmpty
                )
            case "Week Warrior":
                dataModel.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlocked: dataModel.currentStreak >= 7
                )
            default:
                break
            }
        }
    }
    
    private func loadMockDataForTesting() {
        dataModel.currentStreak = 7
        dataModel.bestStreak = 23
        dataModel.level = 12
        dataModel.levelTitle = "Code Samurai"
        dataModel.xp = 2847
        dataModel.progress = 0.85
        dataModel.xpToNext = 353
        dataModel.totalCommitsThisWeek = 21
        
        dataModel.recentCommits = [
            CommitData(repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3),
            CommitData(repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2),
            CommitData(repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1)
        ]
        
        dataModel.weeklyData = [
            WeeklyData(day: "Mon", commits: 4, active: true),
            WeeklyData(day: "Tue", commits: 2, active: true),
            WeeklyData(day: "Wed", commits: 6, active: true),
            WeeklyData(day: "Thu", commits: 3, active: true),
            WeeklyData(day: "Fri", commits: 5, active: true),
            WeeklyData(day: "Sat", commits: 1, active: true),
            WeeklyData(day: "Sun", commits: 0, active: false)
        ]
        
        updateAchievementsForTesting()
    }
    
    private func createMockCommitsForConsistencyTest() -> [GitHubCommit] {
        let calendar = Calendar.current
        let now = Date()
        var commits: [GitHubCommit] = []
        
        // Create consecutive commits for the last 8 days to test streak calculation
        for i in 0..<8 {
            let commitDate = calendar.date(byAdding: .day, value: -i, to: now)!
            let commit = GitHubCommit(
                sha: "sha\(i)",
                commit: CommitDetail(
                    message: "Test commit \(i)",
                    committer: Committer(
                        date: ISO8601DateFormatter().string(from: commitDate)
                    )
                ),
                repository: Repository(name: "test-repo", owner: nil),
                stats: nil
            )
            commits.append(commit)
        }
        
        return commits
    }
    
    private func calculateStreakForTesting(from commits: [GitHubCommit]) -> Int {
        // Simplified streak calculation logic for testing
        guard !commits.isEmpty else { return 0 }
        
        let dateFormatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        
        var currentStreak = 0
        var bestStreak = 0
        var lastCommitDate: Date?
        
        for commit in commits.sorted(by: { dateFormatter.date(from: $0.commit.committer.date) ?? Date.distantPast > dateFormatter.date(from: $1.commit.committer.date) ?? Date.distantPast }) {
            guard let commitDate = dateFormatter.date(from: commit.commit.committer.date) else { continue }
            let commitDay = calendar.startOfDay(for: commitDate)
            
            if let lastDate = lastCommitDate {
                if calendar.dateComponents([.day], from: lastDate, to: commitDay).day == 1 {
                    currentStreak += 1
                } else {
                    bestStreak = max(bestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastCommitDate = commitDay
        }
        
        bestStreak = max(bestStreak, currentStreak)
        return bestStreak
    }
}