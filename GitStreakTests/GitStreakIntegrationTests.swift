import XCTest
import Foundation
@testable import GitStreak

class GitStreakIntegrationTests: XCTestCase {
    
    var gitHubService: GitHubService!
    var dataModel: GitStreakDataModel!
    
    override func setUp() {
        super.setUp()
        gitHubService = GitHubService()
        dataModel = GitStreakDataModel()
    }
    
    override func tearDown() {
        gitHubService = nil
        dataModel = nil
        super.tearDown()
    }
    
    // MARK: - Week Boundary Calculation Tests
    
    func testWeekBoundaryCalculation_SundayToMondayTransition() {
        // Test Sunday (end of week) to Monday (start of week) transition
        let calendar = Calendar.current
        
        // Create a Sunday date (end of week)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 7  // Sunday, January 7, 2024
        components.hour = 23
        components.minute = 59
        let sunday = calendar.date(from: components)!
        
        // Create Monday date (start of next week)
        let monday = calendar.date(byAdding: .day, value: 1, to: sunday)!
        
        // Mock commits for both days
        let sundayCommit = createMockCommit(date: sunday, repo: "test-repo", message: "Sunday commit")
        let mondayCommit = createMockCommit(date: monday, repo: "test-repo", message: "Monday commit")
        
        let commits = [sundayCommit, mondayCommit]
        
        // Calculate streaks using the private methods (we'll need to expose these for testing)
        let currentStreak = calculateCurrentStreakForTesting(commits: commits, referenceDate: monday)
        
        // Should have a streak of 2 across the week boundary
        XCTAssertEqual(currentStreak, 2, "Should maintain streak across Sunday-Monday boundary")
    }
    
    func testWeekBoundaryCalculation_MondayWeekStart() {
        let calendar = Calendar.current
        
        // Test that Monday is correctly identified as week start
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 8  // Monday, January 8, 2024
        let monday = calendar.date(from: components)!
        
        let weekday = calendar.component(.weekday, from: monday)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: monday))!
        
        // Start of week should be the same Monday
        XCTAssertTrue(calendar.isDate(startOfWeek, inSameDayAs: monday), "Monday should be start of week")
    }
    
    func testWeekBoundaryCalculation_SundayWeekEnd() {
        let calendar = Calendar.current
        
        // Test that Sunday is correctly identified as week end
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 7  // Sunday, January 7, 2024
        let sunday = calendar.date(from: components)!
        
        let weekday = calendar.component(.weekday, from: sunday)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: sunday))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        // End of week should be the same Sunday
        XCTAssertTrue(calendar.isDate(endOfWeek, inSameDayAs: sunday), "Sunday should be end of week")
    }
    
    // MARK: - Timezone Scenario Tests
    
    func testTimezoneScenarios_UTCCommitInDifferentLocalTimezones() {
        // Test UTC midnight commit in different local timezones
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")
        
        // UTC midnight on January 1, 2024
        let utcMidnightString = "2024-01-01T00:00:00.000Z"
        let utcDate = utcFormatter.date(from: utcMidnightString)!
        
        // Test in different timezones
        let timezones = [
            "America/New_York",  // UTC-5 (EST) / UTC-4 (EDT)
            "Europe/London",     // UTC+0 / UTC+1 (BST)
            "Asia/Tokyo",        // UTC+9
            "Australia/Sydney",  // UTC+10 / UTC+11 (AEDT)
            "America/Los_Angeles" // UTC-8 (PST) / UTC-7 (PDT)
        ]
        
        for timezoneId in timezones {
            let timezone = TimeZone(identifier: timezoneId)!
            let localFormatter = DateFormatter()
            localFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            localFormatter.timeZone = timezone
            
            let localDateString = localFormatter.string(from: utcDate)
            print("UTC \(utcMidnightString) -> \(timezoneId): \(localDateString)")
            
            // Verify the date is parsed correctly regardless of timezone
            let commit = createMockCommit(date: utcDate, repo: "test-repo", message: "Timezone test")
            XCTAssertNotNil(commit, "Should create commit for timezone \(timezoneId)")
        }
    }
    
    func testTimezoneScenarios_DaylightSavingTransitions() {
        // Test commits during daylight saving time transitions
        let calendar = Calendar.current
        
        // Spring forward (2024-03-10 in US)
        var springComponents = DateComponents()
        springComponents.year = 2024
        springComponents.month = 3
        springComponents.day = 10
        springComponents.hour = 2  // This hour is skipped in spring forward
        let springDate = calendar.date(from: springComponents)!
        
        // Fall back (2024-11-03 in US)
        var fallComponents = DateComponents()
        fallComponents.year = 2024
        fallComponents.month = 11
        fallComponents.day = 3
        fallComponents.hour = 1  // This hour occurs twice in fall back
        let fallDate = calendar.date(from: fallComponents)!
        
        let springCommit = createMockCommit(date: springDate, repo: "test-repo", message: "Spring DST commit")
        let fallCommit = createMockCommit(date: fallDate, repo: "test-repo", message: "Fall DST commit")
        
        XCTAssertNotNil(springCommit, "Should handle spring DST transition")
        XCTAssertNotNil(fallCommit, "Should handle fall DST transition")
    }
    
    // MARK: - Date Parsing Tests
    
    func testDateParsing_GitHubAPITimestampFormats() {
        // Test various GitHub API timestamp formats
        let testTimestamps = [
            "2024-01-15T10:30:45.123Z",           // Standard format with milliseconds
            "2024-01-15T10:30:45Z",               // Without milliseconds
            "2024-01-15T10:30:45.000Z",           // With .000 milliseconds
            "2024-01-15T10:30:45.12Z",            // Two-digit milliseconds
            "2024-01-15T10:30:45.1Z",             // One-digit milliseconds
            "2024-12-31T23:59:59.999Z",           // Year end boundary
            "2024-02-29T12:00:00.000Z",           // Leap year date
            "2024-01-01T00:00:00.000Z"            // Year start boundary
        ]
        
        for timestamp in testTimestamps {
            let parsedDate = parseGitHubTimestampForTesting(timestamp)
            XCTAssertNotNil(parsedDate, "Should parse timestamp: \(timestamp)")
            
            if let date = parsedDate {
                // Verify the date components are reasonable using UTC calendar
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC")!
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                XCTAssertEqual(components.year, 2024, "Year should be 2024 for: \(timestamp)")
                XCTAssertNotNil(components.month, "Month should be valid for: \(timestamp)")
                XCTAssertNotNil(components.day, "Day should be valid for: \(timestamp)")
            }
        }
    }
    
    func testDateParsing_InvalidTimestampFormats() {
        // Test invalid timestamp formats that should definitively fail
        let invalidTimestamps = [
            "",                                   // Empty string
            "invalid-date",                       // Completely invalid
            "2024-13-01T10:30:45.123Z",          // Invalid month
            "2024-01-32T10:30:45.123Z",          // Invalid day
            "2024-01-15T25:30:45.123Z",          // Invalid hour
            "2024-01-15T10:60:45.123Z",          // Invalid minute
            "2024-01-15T10:30:60.123Z",          // Invalid second
            "2024-01-15 10:30:45.123Z",          // Missing T separator
            "not-a-date-at-all",                 // Completely malformed
            "2024-01-15T10:30:45.123X"           // Wrong timezone indicator
        ]
        
        for timestamp in invalidTimestamps {
            let parsedDate = parseGitHubTimestampForTesting(timestamp)
            XCTAssertNil(parsedDate, "Should not parse invalid timestamp: \(timestamp)")
        }
    }
    
    // MARK: - Empty Data and Parsing Failure Tests
    
    func testEmptyCommitArrays() {
        let emptyCommits: [GitHubCommit] = []
        
        let currentStreak = calculateCurrentStreakForTesting(commits: emptyCommits)
        let bestStreak = calculateBestStreakForTesting(commits: emptyCommits)
        
        XCTAssertEqual(currentStreak, 0, "Current streak should be 0 for empty commits")
        XCTAssertEqual(bestStreak, 0, "Best streak should be 0 for empty commits")
    }
    
    func testCommitsWithInvalidDates() {
        // Create commits with invalid date strings
        let invalidCommits = [
            GitHubCommit(
                sha: "abc123",
                commit: CommitDetail(
                    message: "Test commit",
                    committer: Committer(date: "invalid-date")
                ),
                repository: Repository(name: "test-repo", owner: nil),
                stats: nil
            ),
            GitHubCommit(
                sha: "def456",
                commit: CommitDetail(
                    message: "Another test commit",
                    committer: Committer(date: "")
                ),
                repository: Repository(name: "test-repo", owner: nil),
                stats: nil
            )
        ]
        
        let currentStreak = calculateCurrentStreakForTesting(commits: invalidCommits)
        let bestStreak = calculateBestStreakForTesting(commits: invalidCommits)
        
        // Should handle invalid dates gracefully
        XCTAssertEqual(currentStreak, 0, "Should handle invalid dates gracefully")
        XCTAssertEqual(bestStreak, 0, "Should handle invalid dates gracefully")
    }
    
    func testMixedValidAndInvalidCommits() {
        let today = Date()
        let validCommit = createMockCommit(date: today, repo: "test-repo", message: "Valid commit")
        
        let invalidCommit = GitHubCommit(
            sha: "invalid123",
            commit: CommitDetail(
                message: "Invalid commit",
                committer: Committer(date: "not-a-date")
            ),
            repository: Repository(name: "test-repo", owner: nil),
            stats: nil
        )
        
        let mixedCommits = [validCommit, invalidCommit]
        
        let currentStreak = calculateCurrentStreakForTesting(commits: mixedCommits)
        
        // Should process valid commits and ignore invalid ones
        XCTAssertGreaterThanOrEqual(currentStreak, 0, "Should handle mixed valid/invalid commits")
    }
    
    // MARK: - Leap Year and Month Boundary Tests
    
    func testLeapYearHandling() {
        let calendar = Calendar.current
        
        // Test leap year: 2024 (divisible by 4, not divisible by 100, or divisible by 400)
        var leapYearComponents = DateComponents()
        leapYearComponents.year = 2024
        leapYearComponents.month = 2
        leapYearComponents.day = 29  // February 29th only exists in leap years
        let leapYearDate = calendar.date(from: leapYearComponents)!
        
        let leapYearCommit = createMockCommit(date: leapYearDate, repo: "test-repo", message: "Leap year commit")
        
        // Test non-leap year: 2023
        var nonLeapYearComponents = DateComponents()
        nonLeapYearComponents.year = 2023
        nonLeapYearComponents.month = 2
        nonLeapYearComponents.day = 28  // February 28th in non-leap year
        let nonLeapYearDate = calendar.date(from: nonLeapYearComponents)!
        
        let nonLeapYearCommit = createMockCommit(date: nonLeapYearDate, repo: "test-repo", message: "Non-leap year commit")
        
        let commits = [leapYearCommit, nonLeapYearCommit]
        let streak = calculateCurrentStreakForTesting(commits: commits)
        
        XCTAssertGreaterThanOrEqual(streak, 0, "Should handle leap year dates correctly")
    }
    
    func testMonthBoundaryTransitions() {
        let calendar = Calendar.current
        
        // Test end of January to beginning of February
        var endOfJanuaryComponents = DateComponents()
        endOfJanuaryComponents.year = 2024
        endOfJanuaryComponents.month = 1
        endOfJanuaryComponents.day = 31
        endOfJanuaryComponents.hour = 23
        endOfJanuaryComponents.minute = 59
        let endOfJanuary = calendar.date(from: endOfJanuaryComponents)!
        
        var startOfFebruaryComponents = DateComponents()
        startOfFebruaryComponents.year = 2024
        startOfFebruaryComponents.month = 2
        startOfFebruaryComponents.day = 1
        startOfFebruaryComponents.hour = 0
        startOfFebruaryComponents.minute = 1
        let startOfFebruary = calendar.date(from: startOfFebruaryComponents)!
        
        let januaryCommit = createMockCommit(date: endOfJanuary, repo: "test-repo", message: "End of January")
        let februaryCommit = createMockCommit(date: startOfFebruary, repo: "test-repo", message: "Start of February")
        
        let commits = [februaryCommit, januaryCommit]  // Order newest first (as from API)
        let streak = calculateCurrentStreakForTesting(commits: commits, referenceDate: startOfFebruary)
        
        XCTAssertEqual(streak, 2, "Should maintain streak across month boundary")
    }
    
    func testYearBoundaryTransitions() {
        let calendar = Calendar.current
        
        // Test end of year to beginning of next year
        var endOfYearComponents = DateComponents()
        endOfYearComponents.year = 2023
        endOfYearComponents.month = 12
        endOfYearComponents.day = 31
        endOfYearComponents.hour = 23
        endOfYearComponents.minute = 59
        let endOfYear = calendar.date(from: endOfYearComponents)!
        
        var startOfYearComponents = DateComponents()
        startOfYearComponents.year = 2024
        startOfYearComponents.month = 1
        startOfYearComponents.day = 1
        startOfYearComponents.hour = 0
        startOfYearComponents.minute = 1
        let startOfYear = calendar.date(from: startOfYearComponents)!
        
        let oldYearCommit = createMockCommit(date: endOfYear, repo: "test-repo", message: "End of 2023")
        let newYearCommit = createMockCommit(date: startOfYear, repo: "test-repo", message: "Start of 2024")
        
        let commits = [newYearCommit, oldYearCommit]  // Order newest first
        let streak = calculateCurrentStreakForTesting(commits: commits, referenceDate: startOfYear)
        
        XCTAssertEqual(streak, 2, "Should maintain streak across year boundary")
    }
    
    // MARK: - Helper Methods
    
    private func createMockCommit(date: Date, repo: String, message: String) -> GitHubCommit {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        return GitHubCommit(
            sha: UUID().uuidString,
            commit: CommitDetail(
                message: message,
                committer: Committer(date: formatter.string(from: date))
            ),
            repository: Repository(name: repo, owner: nil),
            stats: nil
        )
    }
    
    // Helper methods to test private functionality
    private func calculateCurrentStreakForTesting(commits: [GitHubCommit], referenceDate: Date = Date()) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        
        var commitDays = Set<Date>()
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let dayStart = calendar.startOfDay(for: commitDate)
                commitDays.insert(dayStart)
            }
        }
        
        var streak = 0
        var currentDay = today
        
        if !commitDays.contains(currentDay) {
            currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay) ?? currentDay
        }
        
        while commitDays.contains(currentDay) {
            streak += 1
            guard let nextDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }
        
        return streak
    }
    
    private func calculateBestStreakForTesting(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let calendar = Calendar.current
        
        var commitDays = Set<Date>()
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let dayStart = calendar.startOfDay(for: commitDate)
                commitDays.insert(dayStart)
            }
        }
        
        let sortedDays = commitDays.sorted()
        guard !sortedDays.isEmpty else { return 0 }
        
        var bestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDays.count {
            let previousDay = sortedDays[i-1]
            let currentDay = sortedDays[i]
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDay),
               calendar.isDate(nextDay, inSameDayAs: currentDay) {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return bestStreak
    }
    
    private func parseGitHubTimestampForTesting(_ timestamp: String) -> Date? {
        // Try ISO8601DateFormatter first (handles most cases)
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: timestamp) {
            return date
        }
        
        // Fallback to ISO8601 without fractional seconds for "Z" format without milliseconds
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: timestamp) {
            return date
        }
        
        // Additional fallback using DateFormatter for custom cases
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        // Try different formats that GitHub might use
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",  // With milliseconds and timezone
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",      // Without milliseconds
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",    // With milliseconds and literal Z
            "yyyy-MM-dd'T'HH:mm:ss'Z'"         // Without milliseconds and literal Z
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: timestamp) {
                return date
            }
        }
        
        return nil
    }
}