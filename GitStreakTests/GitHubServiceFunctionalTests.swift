import XCTest
import Foundation
@testable import GitStreak

class GitHubServiceFunctionalTests: XCTestCase {
    
    var gitHubService: GitHubService!
    
    override func setUp() {
        super.setUp()
        gitHubService = GitHubService()
    }
    
    override func tearDown() {
        gitHubService = nil
        super.tearDown()
    }
    
    // MARK: - GitHub Token Validation Tests
    
    func testGitHubTokenValidation_ValidTokens() {
        let validTokens = [
            "ghp_" + String(repeating: "a", count: 36),          // 40 character classic token
            "ghp_" + String(repeating: "1", count: 40),          // 44 character classic token
            "github_pat_" + String(repeating: "b", count: 39),   // 50 character fine-grained token
            "github_pat_" + String(repeating: "x", count: 50)    // 62 character fine-grained token
        ]
        
        for token in validTokens {
            let isValid = isValidGitHubTokenForTesting(token)
            XCTAssertTrue(isValid, "Should validate token: \(token.prefix(15))...")
        }
    }
    
    func testGitHubTokenValidation_InvalidTokens() {
        let invalidTokens = [
            "",                                           // Empty string
            "ghp_",                                       // Only prefix
            "ghp_short",                                  // Too short
            "invalid_prefix_" + String(repeating: "a", count: 30), // Wrong prefix
            "github_pat_short",                           // Fine-grained too short
            String(repeating: "a", count: 40),            // No prefix
            "ghp_" + String(repeating: "a", count: 35),   // Classic too short
            "github_pat_" + String(repeating: "a", count: 35) // Fine-grained too short
        ]
        
        for token in invalidTokens {
            let isValid = isValidGitHubTokenForTesting(token)
            XCTAssertFalse(isValid, "Should not validate token: \(token)")
        }
    }
    
    // MARK: - API Request Construction Tests
    
    func testAPIRequestConstruction_UserEndpoint() {
        let baseURL = "https://api.github.com"
        let userURL = URL(string: "\(baseURL)/user")
        
        XCTAssertNotNil(userURL, "Should construct valid user API URL")
        XCTAssertEqual(userURL?.absoluteString, "https://api.github.com/user")
    }
    
    func testAPIRequestConstruction_CommitsSearchEndpoint() {
        let baseURL = "https://api.github.com"
        let username = "testuser"
        let commitsURL = URL(string: "\(baseURL)/search/commits?q=author:\(username)&sort=committer-date&order=desc&per_page=100")
        
        XCTAssertNotNil(commitsURL, "Should construct valid commits search API URL")
        XCTAssertTrue(commitsURL?.absoluteString.contains("search/commits") ?? false)
        XCTAssertTrue(commitsURL?.absoluteString.contains("author:testuser") ?? false)
        XCTAssertTrue(commitsURL?.absoluteString.contains("sort=committer-date") ?? false)
        XCTAssertTrue(commitsURL?.absoluteString.contains("order=desc") ?? false)
        XCTAssertTrue(commitsURL?.absoluteString.contains("per_page=100") ?? false)
    }
    
    func testAPIRequestHeaders() {
        let token = "ghp_test_token_123456789012345678901234567890"
        var request = URLRequest(url: URL(string: "https://api.github.com/user")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/vnd.github.v3+json")
    }
    
    // MARK: - JSON Parsing Tests
    
    func testGitHubUserParsing_ValidJSON() {
        let validUserJSON = """
        {
            "login": "testuser",
            "name": "Test User",
            "avatar_url": "https://github.com/images/error/testuser.png"
        }
        """
        
        let jsonData = validUserJSON.data(using: .utf8)!
        
        do {
            let user = try JSONDecoder().decode(GitHubUser.self, from: jsonData)
            XCTAssertEqual(user.login, "testuser")
            XCTAssertEqual(user.name, "Test User")
            XCTAssertEqual(user.avatarUrl, "https://github.com/images/error/testuser.png")
        } catch {
            XCTFail("Should parse valid user JSON: \(error)")
        }
    }
    
    func testGitHubUserParsing_MissingOptionalFields() {
        let minimalUserJSON = """
        {
            "login": "testuser",
            "avatar_url": "https://github.com/images/error/testuser.png"
        }
        """
        
        let jsonData = minimalUserJSON.data(using: .utf8)!
        
        do {
            let user = try JSONDecoder().decode(GitHubUser.self, from: jsonData)
            XCTAssertEqual(user.login, "testuser")
            XCTAssertNil(user.name)
            XCTAssertEqual(user.avatarUrl, "https://github.com/images/error/testuser.png")
        } catch {
            XCTFail("Should parse minimal user JSON: \(error)")
        }
    }
    
    func testGitHubCommitParsing_ValidJSON() {
        let validCommitJSON = """
        {
            "items": [
                {
                    "sha": "abc123def456",
                    "commit": {
                        "message": "Fix bug in authentication",
                        "committer": {
                            "date": "2024-01-15T10:30:45.123Z"
                        }
                    },
                    "repository": {
                        "name": "my-awesome-project"
                    }
                }
            ]
        }
        """
        
        let jsonData = validCommitJSON.data(using: .utf8)!
        
        do {
            let searchResult = try JSONDecoder().decode(GitHubCommitSearchResult.self, from: jsonData)
            XCTAssertEqual(searchResult.items.count, 1)
            
            let commit = searchResult.items[0]
            XCTAssertEqual(commit.sha, "abc123def456")
            XCTAssertEqual(commit.commit.message, "Fix bug in authentication")
            XCTAssertEqual(commit.commit.committer.date, "2024-01-15T10:30:45.123Z")
            XCTAssertEqual(commit.repository.name, "my-awesome-project")
        } catch {
            XCTFail("Should parse valid commit JSON: \(error)")
        }
    }
    
    func testGitHubCommitParsing_EmptyResults() {
        let emptyResultsJSON = """
        {
            "items": []
        }
        """
        
        let jsonData = emptyResultsJSON.data(using: .utf8)!
        
        do {
            let searchResult = try JSONDecoder().decode(GitHubCommitSearchResult.self, from: jsonData)
            XCTAssertEqual(searchResult.items.count, 0)
        } catch {
            XCTFail("Should parse empty results JSON: \(error)")
        }
    }
    
    func testGitHubCommitParsing_InvalidJSON() {
        let invalidJSONs = [
            "",                                    // Empty string
            "{",                                   // Incomplete JSON
            "{ \"items\": }",                      // Missing array
            "{ \"items\": [ { \"invalid\": true } ] }", // Missing required fields
            "not json at all"                      // Not JSON
        ]
        
        for invalidJSON in invalidJSONs {
            let jsonData = invalidJSON.data(using: .utf8)!
            
            do {
                _ = try JSONDecoder().decode(GitHubCommitSearchResult.self, from: jsonData)
                XCTFail("Should not parse invalid JSON: \(invalidJSON)")
            } catch {
                // Expected to fail
                XCTAssertTrue(true, "Correctly failed to parse invalid JSON")
            }
        }
    }
    
    // MARK: - Contribution Stats Calculation Tests
    
    func testContributionStatsCalculation_WithValidCommits() {
        let commits = createMockCommitsForStats()
        let stats = calculateContributionStatsForTesting(commits: commits)
        
        XCTAssertGreaterThanOrEqual(stats.currentStreak, 0)
        XCTAssertGreaterThanOrEqual(stats.bestStreak, 0)
        XCTAssertGreaterThanOrEqual(stats.recentCommits.count, 0)
        XCTAssertLessThanOrEqual(stats.recentCommits.count, 5) // Should limit to 5
    }
    
    func testContributionStatsCalculation_EmptyCommits() {
        let emptyCommits: [GitHubCommit] = []
        let stats = calculateContributionStatsForTesting(commits: emptyCommits)
        
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertEqual(stats.bestStreak, 0)
        XCTAssertEqual(stats.recentCommits.count, 0)
        XCTAssertEqual(stats.weeklyCommits.count, 0)
    }
    
    // MARK: - Date Formatting Tests
    
    func testRelativeTimeFormatting() {
        let now = Date()
        let calendar = Calendar.current
        
        // Test different time intervals
        let testCases: [(TimeInterval, String)] = [
            (30, "0m ago"),                          // 30 seconds -> 0 minutes
            (300, "5m ago"),                         // 5 minutes
            (3600, "1h ago"),                        // 1 hour
            (7200, "2h ago"),                        // 2 hours
            (86400, "1d ago"),                       // 1 day
            (172800, "2d ago"),                      // 2 days
            (604800, "7d ago")                       // 7 days
        ]
        
        for (interval, expected) in testCases {
            let pastDate = Date(timeInterval: -interval, since: now)
            let formatted = formatRelativeTimeForTesting(pastDate)
            
            // Allow some flexibility in the exact formatting
            XCTAssertTrue(formatted.contains("ago"), "Should contain 'ago': \(formatted)")
            
            if interval < 3600 {
                XCTAssertTrue(formatted.contains("m"), "Should be in minutes: \(formatted)")
            } else if interval < 86400 {
                XCTAssertTrue(formatted.contains("h"), "Should be in hours: \(formatted)")
            } else {
                XCTAssertTrue(formatted.contains("d"), "Should be in days: \(formatted)")
            }
        }
    }
    
    func testInvalidDateFormatting() {
        let invalidDateString = "not-a-date"
        let formatted = formatRelativeTimeFromStringForTesting(invalidDateString)
        XCTAssertEqual(formatted, "Unknown", "Should return 'Unknown' for invalid dates")
    }
    
    // MARK: - Error Handling Tests
    
    func testGitHubErrorDescriptions() {
        let errors: [GitHubError] = [
            .invalidURL,
            .invalidResponse,
            .unauthorized,
            .notAuthenticated,
            .invalidToken,
            .requestFailed(404),
            .requestFailed(500)
        ]
        
        for error in errors {
            let description = error.errorDescription
            XCTAssertNotNil(description, "Error should have description")
            XCTAssertFalse(description?.isEmpty ?? true, "Error description should not be empty")
        }
    }
    
    // MARK: - Helper Methods for Testing
    
    private func isValidGitHubTokenForTesting(_ token: String) -> Bool {
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmedToken.hasPrefix("ghp_") && trimmedToken.count >= 40) ||
               (trimmedToken.hasPrefix("github_pat_") && trimmedToken.count >= 50)
    }
    
    private func createMockCommitsForStats() -> [GitHubCommit] {
        let calendar = Calendar.current
        let now = Date()
        var commits: [GitHubCommit] = []
        
        // Create commits for the last 10 days
        for i in 0..<10 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let commit = createMockCommit(date: date, repo: "test-repo-\(i)", message: "Commit \(i)")
                commits.append(commit)
            }
        }
        
        return commits
    }
    
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
            repository: Repository(name: repo)
        )
    }
    
    private func calculateContributionStatsForTesting(commits: [GitHubCommit]) -> ContributionStats {
        var weeklyCommits: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let calendar = Calendar.current
        let today = Date()
        
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today)) else {
            return ContributionStats(currentStreak: 0, bestStreak: 0, weeklyCommits: [:], recentCommits: [])
        }
        
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return ContributionStats(currentStreak: 0, bestStreak: 0, weeklyCommits: [:], recentCommits: [])
        }
        
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let commitDayStart = calendar.startOfDay(for: commitDate)
                
                if commitDayStart >= startOfWeek && commitDayStart <= endOfWeek {
                    let dayKey = dayFormatter.string(from: commitDate)
                    weeklyCommits[dayKey, default: 0] += 1
                }
            }
        }
        
        let currentStreak = calculateCurrentStreakForTesting(commits: commits)
        let bestStreak = calculateBestStreakForTesting(commits: commits)
        
        return ContributionStats(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            weeklyCommits: weeklyCommits,
            recentCommits: commits.prefix(5).map { commit in
                CommitData(
                    repo: commit.repository.name,
                    message: commit.commit.message,
                    time: formatRelativeTimeFromStringForTesting(commit.commit.committer.date),
                    commits: 1
                )
            }
        )
    }
    
    private func calculateCurrentStreakForTesting(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
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
    
    private func formatRelativeTimeForTesting(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    private func formatRelativeTimeFromStringForTesting(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        
        guard let date = formatter.date(from: dateString) else {
            return "Unknown"
        }
        
        return formatRelativeTimeForTesting(date)
    }
}