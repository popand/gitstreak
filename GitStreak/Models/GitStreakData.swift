import Foundation
import SwiftUI
import Security

// MARK: - Keychain Helper
class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    func delete(service: String, account: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

extension KeychainHelper {
    private static let service = "com.gitstreak.app"
    
    func saveToken(_ token: String, forKey key: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        return save(data, service: KeychainHelper.service, account: key)
    }
    
    func getToken(forKey key: String) -> String? {
        guard let data = read(service: KeychainHelper.service, account: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken(forKey key: String) -> Bool {
        return delete(service: KeychainHelper.service, account: key)
    }
}

// MARK: - GitHub Service
class GitHubService: ObservableObject {
    static let shared = GitHubService()
    
    @Published var isAuthenticated = false
    @Published var username: String?
    @Published var accessToken: String?
    
    private let baseURL = "https://api.github.com"
    private let tokenKey = "github_access_token"
    private let usernameKey = "github_username"
    
    init() {
        loadStoredCredentials()
    }
    
    private func loadStoredCredentials() {
        if let token = KeychainHelper.shared.getToken(forKey: tokenKey),
           let username = KeychainHelper.shared.getToken(forKey: usernameKey) {
            self.accessToken = token
            self.username = username
            self.isAuthenticated = true
        }
    }
    
    func authenticate(token: String) async throws {
        // Validate token format before making API calls
        guard isValidGitHubToken(token) else {
            throw GitHubError.invalidToken
        }
        
        let user = try await fetchUser(token: token)
        
        await MainActor.run {
            self.accessToken = token
            self.username = user.login
            self.isAuthenticated = true
            
            _ = KeychainHelper.shared.saveToken(token, forKey: tokenKey)
            _ = KeychainHelper.shared.saveToken(user.login, forKey: usernameKey)
        }
    }
    
    func logout() {
        accessToken = nil
        username = nil
        isAuthenticated = false
        
        _ = KeychainHelper.shared.deleteToken(forKey: tokenKey)
        _ = KeychainHelper.shared.deleteToken(forKey: usernameKey)
    }
    
    private func fetchUser(token: String) async throws -> GitHubUser {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw GitHubError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(GitHubUser.self, from: data)
    }
    
    func fetchUserCommits() async throws -> [GitHubCommit] {
        guard let token = accessToken, let username = username else {
            throw GitHubError.notAuthenticated
        }
        
        // Fetch user's repositories first
        guard let reposUrl = URL(string: "\(baseURL)/user/repos?sort=pushed&per_page=10") else {
            throw GitHubError.invalidURL
        }
        
        var reposRequest = URLRequest(url: reposUrl)
        reposRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        reposRequest.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (reposData, reposResponse) = try await URLSession.shared.data(for: reposRequest)
        
        guard let reposHttpResponse = reposResponse as? HTTPURLResponse,
              reposHttpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed((reposResponse as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let repositories = try JSONDecoder().decode([GitHubRepository].self, from: reposData)
        
        print("🔍 Checking repositories: \(repositories.prefix(5).map { $0.name }.joined(separator: ", "))")
        
        // Fetch commits from user's repositories with stats
        var allCommits: [GitHubCommit] = []
        
        for repo in repositories.prefix(5) { // Limit to 5 repos to avoid rate limiting
            if let commits = try? await fetchRepositoryCommits(owner: username, repo: repo.name) {
                allCommits.append(contentsOf: commits) // Include all commits from last 30 days
            }
        }
        
        print("📊 Total commits found: \(allCommits.count)")
        
        // Sort by commit date
        allCommits.sort { commit1, commit2 in
            let dateFormatter = ISO8601DateFormatter()
            
            guard let date1 = dateFormatter.date(from: commit1.commit.committer.date),
                  let date2 = dateFormatter.date(from: commit2.commit.committer.date) else {
                return false
            }
            return date1 > date2
        }
        
        return Array(allCommits.prefix(150)) // Allow more commits since we're filtering by date
    }
    
    private func fetchRepositoryCommits(owner: String, repo: String) async throws -> [GitHubCommit]? {
        guard let token = accessToken else { return nil }
        
        // Get commits from the last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let sinceDate = ISO8601DateFormatter().string(from: thirtyDaysAgo)
        
        guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/commits?since=\(sinceDate)&per_page=30") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ No HTTP response for \(repo)")
            return nil
        }
        
        print("📍 Fetching \(repo): Status \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Error \(httpResponse.statusCode) for \(repo)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("Error response: \(errorData)")
            }
            return nil
        }
        
        do {
            let repositoryCommits = try JSONDecoder().decode([RepositoryCommit].self, from: data)
            print("✅ Found \(repositoryCommits.count) commits in \(repo)")
            
            // Fetch detailed stats for the first 5 commits only (to avoid rate limits)
            let commitsWithStats = await withTaskGroup(of: GitHubCommit?.self) { group in
                // Add tasks for first 5 commits to get detailed stats
                for (index, repoCommit) in repositoryCommits.enumerated() {
                    if index < 5 {
                        group.addTask {
                            return await self.fetchCommitWithStats(owner: owner, repo: repo, sha: repoCommit.sha, baseCommit: repoCommit)
                        }
                    }
                }
                
                // Collect results with stats
                var statsResults: [GitHubCommit] = []
                for await commit in group {
                    if let commit = commit {
                        statsResults.append(commit)
                    }
                }
                
                // Create final results - simpler and safer approach
                var finalResults: [GitHubCommit] = []
                for (_, repoCommit) in repositoryCommits.enumerated() {
                    if let commitWithStats = statsResults.first(where: { $0.sha == repoCommit.sha }) {
                        // Use commit with stats if available
                        finalResults.append(commitWithStats)
                    } else {
                        // Fallback for all commits without stats (either failed fetch or not attempted)
                        finalResults.append(GitHubCommit(
                            sha: repoCommit.sha,
                            commit: repoCommit.commit,
                            repository: Repository(name: repo, owner: nil),
                            stats: nil
                        ))
                    }
                }
                
                return finalResults
            }
            
            return commitsWithStats
        } catch {
            print("❌ JSON decode error for \(repo): \(error)")
            return nil
        }
    }
    
    private func fetchCommitWithStats(owner: String, repo: String, sha: String, baseCommit: RepositoryCommit) async -> GitHubCommit? {
        guard let token = accessToken else { return nil }
        
        guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/commits/\(sha)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            let individualCommit = try JSONDecoder().decode(IndividualCommit.self, from: data)
            // Convert to GitHubCommit with repository info
            return GitHubCommit(
                sha: individualCommit.sha,
                commit: individualCommit.commit,
                repository: Repository(name: repo, owner: nil),
                stats: individualCommit.stats
            )
        } catch {
            print("❌ Failed to fetch stats for commit \(sha): \(error)")
            // Return commit without stats as fallback
            return GitHubCommit(
                sha: baseCommit.sha,
                commit: baseCommit.commit,
                repository: Repository(name: repo, owner: nil),
                stats: nil
            )
        }
    }
    
    func fetchContributionStats() async throws -> ContributionStats {
        guard username != nil else {
            throw GitHubError.notAuthenticated
        }
        
        let commits = try await fetchUserCommits()
        
        var weeklyCommits: [String: Int] = [:]
        let dateFormatter = ISO8601DateFormatter()
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2 // Sunday = 1, so Sunday needs 6 days back to Monday
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today)) else {
            throw GitHubError.invalidResponse
        }
        
        // Get the end of the current week (Sunday)
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            throw GitHubError.invalidResponse
        }
        
        // Filter commits to only include those from the current week
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let commitDayStart = calendar.startOfDay(for: commitDate)
                
                // Check if commit is within the current week
                if commitDayStart >= startOfWeek && commitDayStart <= endOfWeek {
                    let dayKey = dayFormatter.string(from: commitDate)
                    weeklyCommits[dayKey, default: 0] += 1
                }
            }
        }
        
        let currentStreak = calculateCurrentStreak(commits: commits)
        let bestStreak = calculateBestStreak(commits: commits)
        
        // Get all commits from the past 30 days for monthly view
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        print("📅 Date filter: thirtyDaysAgo = \(thirtyDaysAgo), today = \(today)")
        
        let monthlyCommitData = commits.compactMap { commit -> CommitData? in
            guard let commitDate = dateFormatter.date(from: commit.commit.committer.date) else { 
                print("❌ Failed to parse date: \(commit.commit.committer.date)")
                return nil 
            }
            
            print("🕐 Commit date: \(commitDate), is >= thirtyDaysAgo? \(commitDate >= thirtyDaysAgo)")
            
            if commitDate >= thirtyDaysAgo {
                let timeString = formatRelativeTime(commit.commit.committer.date)
                print("🕐 Formatting time for commit: '\(commit.commit.committer.date)' -> '\(timeString)'")
                return CommitData(
                    repo: commit.repository.name,
                    message: commit.commit.message,
                    time: timeString,
                    commits: 1,
                    additions: commit.stats?.additions,
                    deletions: commit.stats?.deletions
                )
            }
            return nil
        }
        
        print("📅 Monthly commits found: \(monthlyCommitData.count)")
        
        return ContributionStats(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            weeklyCommits: weeklyCommits,
            recentCommits: commits.prefix(5).map { commit in
                CommitData(
                    repo: commit.repository.name,
                    message: commit.commit.message,
                    time: formatRelativeTime(commit.commit.committer.date),
                    commits: 1
                )
            },
            monthlyCommits: monthlyCommitData
        )
    }
    
    private func calculateCurrentStreak(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        // Parse commit dates and convert to local timezone
        let dateFormatter = ISO8601DateFormatter()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group commits by date (day only, in local timezone)
        var commitDays = Set<Date>()
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let dayStart = calendar.startOfDay(for: commitDate)
                commitDays.insert(dayStart)
            }
        }
        
        // Calculate streak starting from today going backwards
        var streak = 0
        var currentDay = today
        
        // Check if today has commits, if not check yesterday as starting point
        if !commitDays.contains(currentDay) {
            currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay) ?? currentDay
        }
        
        // Count consecutive days with commits going backwards from current day
        while commitDays.contains(currentDay) {
            streak += 1
            guard let nextDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }
        
        return streak
    }
    
    private func calculateBestStreak(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        // Parse commit dates and convert to local timezone
        let dateFormatter = ISO8601DateFormatter()
        
        let calendar = Calendar.current
        
        // Group commits by date (day only, in local timezone)
        var commitDays = Set<Date>()
        for commit in commits {
            if let commitDate = dateFormatter.date(from: commit.commit.committer.date) {
                let dayStart = calendar.startOfDay(for: commitDate)
                commitDays.insert(dayStart)
            }
        }
        
        // Convert to sorted array for streak calculation
        let sortedDays = commitDays.sorted()
        guard !sortedDays.isEmpty else { return 0 }
        
        var bestStreak = 1
        var currentStreak = 1
        
        // Find longest consecutive sequence of days
        for i in 1..<sortedDays.count {
            let previousDay = sortedDays[i-1]
            let currentDay = sortedDays[i]
            
            // Check if current day is exactly one day after previous day
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
    
    private func formatRelativeTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        
        guard let date = formatter.date(from: dateString) else {
            print("❌ Failed to parse time string: '\(dateString)'")
            return "Unknown"
        }
        
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
    
    private func isValidGitHubToken(_ token: String) -> Bool {
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if token has the correct prefix and minimum length
        // GitHub Personal Access Tokens (classic) start with "ghp_" and are 40+ characters
        // GitHub Fine-grained Personal Access Tokens start with "github_pat_" and are longer
        return (trimmedToken.hasPrefix("ghp_") && trimmedToken.count >= 40) ||
               (trimmedToken.hasPrefix("github_pat_") && trimmedToken.count >= 50)
    }
}

// MARK: - GitHub Models
struct GitHubUser: Codable {
    let login: String
    let name: String?
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login, name
        case avatarUrl = "avatar_url"
    }
}

struct GitHubCommit: Codable {
    let sha: String
    let commit: CommitDetail
    let repository: Repository
    let stats: CommitStats?
}

struct RepositoryCommit: Codable {
    let sha: String
    let commit: CommitDetail
    let stats: CommitStats?
}

struct IndividualCommit: Codable {
    let sha: String
    let commit: CommitDetail
    let stats: CommitStats?
}

struct CommitDetail: Codable {
    let message: String
    let committer: Committer
}

struct CommitStats: Codable {
    let additions: Int?
    let deletions: Int?
    let total: Int?
}

struct Committer: Codable {
    let date: String
}

struct Repository: Codable {
    let name: String
    let owner: RepositoryOwner?
}

struct RepositoryOwner: Codable {
    let login: String
}

struct GitHubRepository: Codable {
    let name: String
    let fullName: String
    let pushedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case pushedAt = "pushed_at"
    }
}

struct GitHubCommitSearchResult: Codable {
    let items: [GitHubCommit]
}

struct ContributionStats {
    let currentStreak: Int
    let bestStreak: Int
    let weeklyCommits: [String: Int]
    let recentCommits: [CommitData]
    let monthlyCommits: [CommitData]
}

enum GitHubError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notAuthenticated
    case invalidToken
    case requestFailed(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Invalid GitHub token"
        case .notAuthenticated:
            return "Not authenticated"
        case .invalidToken:
            return "Invalid token format. Please use a valid GitHub Personal Access Token (starts with 'ghp_' or 'github_pat_')"
        case .requestFailed(let code):
            return "Request failed with code \(code)"
        }
    }
}

// MARK: - Data Models

struct CommitData: Identifiable {
    let id = UUID()
    let repo: String
    let message: String
    let time: String
    let commits: Int
    var additions: Int?
    var deletions: Int?
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
    let category: AchievementCategory
    
    init(title: String, description: String, icon: String, unlocked: Bool, category: AchievementCategory = .streaks) {
        self.title = title
        self.description = description
        self.icon = icon
        self.unlocked = unlocked
        self.category = category
    }
}

enum AchievementCategory: String, CaseIterable {
    case streaks = "🔥 Streaks"
    case volume = "📊 Volume" 
    case dailyPatterns = "⏰ Daily Patterns"
    case weeklyPatterns = "📅 Weekly Patterns"
    case codeImpact = "💥 Code Impact"
    case repositoryDiversity = "🏗️ Repository Diversity"
    case specialMilestones = "🎯 Special Milestones"
    
    var emoji: String {
        switch self {
        case .streaks: return "🔥"
        case .volume: return "📊"
        case .dailyPatterns: return "⏰"
        case .weeklyPatterns: return "📅"
        case .codeImpact: return "💥"
        case .repositoryDiversity: return "🏗️"
        case .specialMilestones: return "🎯"
        }
    }
    
    var displayName: String {
        switch self {
        case .streaks: return "Streaks"
        case .volume: return "Volume"
        case .dailyPatterns: return "Daily Patterns"
        case .weeklyPatterns: return "Weekly Patterns"
        case .codeImpact: return "Code Impact"
        case .repositoryDiversity: return "Repository Diversity"
        case .specialMilestones: return "Special Milestones"
        }
    }
}

class GitStreakDataModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var level: Int = 1
    @Published var levelTitle: String = "Beginner"
    @Published var xp: Int = 0
    @Published var progress: Double = 0.0
    @Published var xpToNext: Int = 100
    @Published var totalCommitsThisWeek: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var recentCommits: [CommitData] = []
    @Published var monthlyCommits: [CommitData] = []
    @Published var weeklyData: [WeeklyData] = [
        WeeklyData(day: "Mon", commits: 0, active: false),
        WeeklyData(day: "Tue", commits: 0, active: false),
        WeeklyData(day: "Wed", commits: 0, active: false),
        WeeklyData(day: "Thu", commits: 0, active: false),
        WeeklyData(day: "Fri", commits: 0, active: false),
        WeeklyData(day: "Sat", commits: 0, active: false),
        WeeklyData(day: "Sun", commits: 0, active: false)
    ]
    
    @Published var achievements: [Achievement] = [
        // Streak Achievements 🔥 (9 total)
        Achievement(title: "First Flame", description: "Start your first coding streak", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Getting Warmed Up", description: "Keep the momentum going", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Week Warrior", description: "One full week of coding", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Fortnight Fighter", description: "Two weeks strong", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Monthly Master", description: "30 days of dedication", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Quarter Champion", description: "90 days of excellence", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Half-Year Hero", description: "Six months of consistency", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Annual Achiever", description: "A full year of coding", icon: "🔥", unlocked: false, category: .streaks),
        Achievement(title: "Legend Status", description: "Ultimate dedication", icon: "🔥", unlocked: false, category: .streaks),
        
        // Volume Achievements 📊 (8 total)
        Achievement(title: "First Steps", description: "Your coding journey begins", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Getting Started", description: "Building momentum", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Century Club", description: "Triple digits!", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Half Grand", description: "Halfway to a thousand", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Grand Master", description: "Four digits of dedication", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Mega Committer", description: "Serious productivity", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Ultra Producer", description: "Incredible output", icon: "📊", unlocked: false, category: .volume),
        Achievement(title: "Code Machine", description: "Unstoppable force", icon: "📊", unlocked: false, category: .volume),
        
        // Daily Pattern Achievements ⏰ (8 total)
        Achievement(title: "Early Bird", description: "Code before the world wakes up", icon: "🌅", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Morning Person", description: "Start the day with code", icon: "☀️", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Lunch Coder", description: "Productive lunch breaks", icon: "🍽️", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Afternoon Warrior", description: "Steady afternoon work", icon: "☁️", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Evening Developer", description: "After-hours dedication", icon: "🌆", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Night Owl", description: "Burning the midnight oil", icon: "🦉", unlocked: false, category: .dailyPatterns),
        Achievement(title: "All-Day All-Night", description: "Commits in all 4 time periods", icon: "⏰", unlocked: false, category: .dailyPatterns),
        Achievement(title: "Round the Clock", description: "24-hour coding marathon", icon: "🕛", unlocked: false, category: .dailyPatterns),
        
        // Weekly Pattern Achievements 📅 (6 total)
        Achievement(title: "Weekend Warrior", description: "No rest for the committed", icon: "🛡️", unlocked: false, category: .weeklyPatterns),
        Achievement(title: "Weekday Hero", description: "Professional dedication", icon: "💼", unlocked: false, category: .weeklyPatterns),
        Achievement(title: "Perfect Week", description: "Every single day", icon: "✨", unlocked: false, category: .weeklyPatterns),
        Achievement(title: "Monday Motivator", description: "Start the week strong", icon: "💪", unlocked: false, category: .weeklyPatterns),
        Achievement(title: "Friday Finisher", description: "End the week right", icon: "🎯", unlocked: false, category: .weeklyPatterns),
        Achievement(title: "Hump Day Helper", description: "Wednesday productivity", icon: "🐪", unlocked: false, category: .weeklyPatterns),
        
        // Code Impact Achievements 💥 (8 total)
        Achievement(title: "First Impact", description: "Your first code changes", icon: "💥", unlocked: false, category: .codeImpact),
        Achievement(title: "Small Changes", description: "Steady improvements", icon: "🔧", unlocked: false, category: .codeImpact),
        Achievement(title: "Code Builder", description: "Significant contributions", icon: "🏗️", unlocked: false, category: .codeImpact),
        Achievement(title: "Major Contributor", description: "Substantial impact", icon: "🌟", unlocked: false, category: .codeImpact),
        Achievement(title: "Code Architect", description: "Massive contributions", icon: "🏛️", unlocked: false, category: .codeImpact),
        Achievement(title: "Legacy Creator", description: "Epic scale development", icon: "🏆", unlocked: false, category: .codeImpact),
        Achievement(title: "Refactor Master", description: "Clean up specialist", icon: "🧹", unlocked: false, category: .codeImpact),
        Achievement(title: "Efficiency Expert", description: "Balanced changes", icon: "⚖️", unlocked: false, category: .codeImpact),
        
        // Repository Diversity 🏗️ (5 total)
        Achievement(title: "Multi-Tasker", description: "Juggling projects", icon: "🤹", unlocked: false, category: .repositoryDiversity),
        Achievement(title: "Project Hopper", description: "Diverse contributions", icon: "🦘", unlocked: false, category: .repositoryDiversity),
        Achievement(title: "Polyglot", description: "Many languages, one coder", icon: "🌍", unlocked: false, category: .repositoryDiversity),
        Achievement(title: "Portfolio Builder", description: "Broad experience", icon: "📁", unlocked: false, category: .repositoryDiversity),
        Achievement(title: "Open Source Hero", description: "Community contributor", icon: "🌟", unlocked: false, category: .repositoryDiversity),
        
        // Special Milestones 🎯 (8 total)
        Achievement(title: "Speed Runner", description: "Lightning fast development", icon: "⚡", unlocked: false, category: .specialMilestones),
        Achievement(title: "Marathon Coder", description: "Extended coding session", icon: "🏃", unlocked: false, category: .specialMilestones),
        Achievement(title: "Commit Storm", description: "Intense productivity", icon: "⛈️", unlocked: false, category: .specialMilestones),
        Achievement(title: "Message Master", description: "Descriptive commits", icon: "✍️", unlocked: false, category: .specialMilestones),
        Achievement(title: "Consistency King", description: "Steady as a rock", icon: "👑", unlocked: false, category: .specialMilestones),
        Achievement(title: "Streak Saver", description: "Never give up", icon: "🛡️", unlocked: false, category: .specialMilestones),
        Achievement(title: "New Year Coder", description: "Start the year right", icon: "🎊", unlocked: false, category: .specialMilestones),
        Achievement(title: "Birthday Coder", description: "Code on your special day", icon: "🎂", unlocked: false, category: .specialMilestones)
    ]
    
    @Published var totalAchievementXP: Int = 0
    @Published var unlockedAchievementCount: Int = 0  
    @Published var recentlyUnlockedAchievements: [Achievement] = []
    
    private let gitHubService = GitHubService.shared
    
    init() {
        if gitHubService.isAuthenticated {
            loadGitHubData()
        } else {
            loadMockData()
        }
    }
    
    func loadGitHubData() {
        Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                let stats = try await gitHubService.fetchContributionStats()
                
                await MainActor.run {
                    self.currentStreak = stats.currentStreak
                    self.bestStreak = stats.bestStreak
                    self.recentCommits = Array(stats.recentCommits)
                    self.monthlyCommits = stats.monthlyCommits
                    self.updateWeeklyData(from: stats.weeklyCommits)
                    self.calculateLevel()
                    self.updateAchievements()
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.loadMockData()
                }
            }
        }
    }
    
    private func loadMockData() {
        currentStreak = 7
        bestStreak = 23
        level = 12
        levelTitle = "Code Samurai"
        xp = 2847
        progress = 0.85
        xpToNext = 353
        totalCommitsThisWeek = 21
        
        recentCommits = [
            CommitData(repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3),
            CommitData(repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2),
            CommitData(repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1)
        ]
        
        // Generate mock monthly commits
        monthlyCommits = [
            CommitData(repo: "gitstreak", message: "Add .claude to .gitignore for improved file management", time: "3d ago", commits: 1, additions: 15, deletions: 2),
            CommitData(repo: "large-refactor", message: "Major refactoring:\n- Updated all legacy components\n- Added new TypeScript definitions\n- Fixed multiple performance issues\n- Updated documentation", time: "1d ago", commits: 1, additions: 2500, deletions: 1200),
            CommitData(repo: "data-migration", message: "Migrate database schema\n\nThis commit includes:\n\t- New table structures\n\t- Data migration scripts\n\t- Updated indexes", time: "2d ago", commits: 1, additions: 15000, deletions: 8500),
            CommitData(repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3, additions: 124, deletions: 45),
            CommitData(repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2, additions: 89, deletions: 12),
            CommitData(repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1, additions: 34, deletions: 8),
            CommitData(repo: "mobile-app", message: "Implement push notifications", time: "2d ago", commits: 4, additions: 256, deletions: 23),
            CommitData(repo: "documentation", message: "Update API documentation", time: "3d ago", commits: 1, additions: 78, deletions: 15),
            CommitData(repo: "backend-services", message: "Optimize database queries", time: "4d ago", commits: 2, additions: 167, deletions: 89),
            CommitData(repo: "frontend-lib", message: "Add TypeScript definitions", time: "5d ago", commits: 3, additions: 234, deletions: 0),
            CommitData(repo: "testing-suite", message: "Add integration tests", time: "6d ago", commits: 5, additions: 456, deletions: 34),
            CommitData(repo: "cli-tools", message: "Refactor command parser", time: "7d ago", commits: 2, additions: 123, deletions: 78),
            CommitData(repo: "data-pipeline", message: "Add data validation", time: "8d ago", commits: 3, additions: 289, deletions: 56),
            CommitData(repo: "web-scraper", message: "Fix rate limiting issue", time: "9d ago", commits: 1, additions: 45, deletions: 12),
            CommitData(repo: "analytics-dashboard", message: "Add new charts", time: "10d ago", commits: 4, additions: 378, deletions: 89),
            CommitData(repo: "payment-service", message: "Implement Stripe webhook", time: "11d ago", commits: 2, additions: 234, deletions: 45),
            CommitData(repo: "auth-module", message: "Add OAuth2 support", time: "12d ago", commits: 6, additions: 567, deletions: 123)
        ]
        
        weeklyData = [
            WeeklyData(day: "Mon", commits: 4, active: true),
            WeeklyData(day: "Tue", commits: 2, active: true),
            WeeklyData(day: "Wed", commits: 6, active: true),
            WeeklyData(day: "Thu", commits: 3, active: true),
            WeeklyData(day: "Fri", commits: 5, active: true),
            WeeklyData(day: "Sat", commits: 1, active: true),
            WeeklyData(day: "Sun", commits: 7, active: true)
        ]
        
        // Unlock some demo achievements from different categories
        for i in 0..<achievements.count {
            let achievement = achievements[i]
            switch achievement.title {
            case "First Flame":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            case "Week Warrior":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            case "First Steps":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            case "Getting Started":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            case "Early Bird":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            case "First Impact":
                achievements[i] = Achievement(title: achievement.title, description: achievement.description, icon: achievement.icon, unlocked: true, category: achievement.category)
            default:
                break
            }
        }
        
        updateAchievementStats()
    }
    
    private func updateWeeklyData(from commits: [String: Int]) {
        for i in 0..<weeklyData.count {
            let day = weeklyData[i].day
            let commitCount = commits[day] ?? 0
            weeklyData[i] = WeeklyData(day: day, commits: commitCount, active: commitCount > 0)
        }
        totalCommitsThisWeek = commits.values.reduce(0, +)
    }
    
    private func calculateLevel() {
        let totalCommits = totalCommitsThisWeek + (currentStreak * 2)
        level = max(1, totalCommits / 10)
        xp = totalCommits * 100
        xpToNext = ((level + 1) * 10 * 100) - xp
        progress = Double(xp % 1000) / 1000.0
        
        levelTitle = getLevelTitle(for: level)
    }
    
    private func getLevelTitle(for level: Int) -> String {
        switch level {
        case 1...5: return "Beginner"
        case 6...10: return "Code Ninja"
        case 11...20: return "Code Samurai"
        case 21...30: return "Git Master"
        default: return "Code Legend"
        }
    }
    
    private func updateAchievements() {
        achievements[0] = Achievement(title: "First Commit", description: "Make your first commit", icon: "🌱", unlocked: !recentCommits.isEmpty, category: .streaks)
        achievements[1] = Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: currentStreak >= 7, category: .streaks)
        updateAchievementStats()
    }
    
    private func updateAchievementStats() {
        unlockedAchievementCount = achievements.filter { $0.unlocked }.count
        totalAchievementXP = unlockedAchievementCount * 100 // Simple XP calculation for demo
        recentlyUnlockedAchievements = achievements.filter { $0.unlocked }
    }
    
    func refreshData() {
        if gitHubService.isAuthenticated {
            loadGitHubData()
        } else {
            loadMockData()
        }
    }
    
    // MARK: - Computed Properties for Stats
    
    var mostActiveWeekDay: String {
        let dayMapping = ["Mon": "Monday", "Tue": "Tuesday", "Wed": "Wednesday", 
                         "Thu": "Thursday", "Fri": "Friday", "Sat": "Saturday", "Sun": "Sunday"]
        
        let mostActiveDay = weeklyData.max { $0.commits < $1.commits }?.day ?? "Monday"
        return dayMapping[mostActiveDay] ?? "Monday"
    }
    
    var dailyCommitAverage: Double {
        let totalCommits = weeklyData.reduce(0) { $0 + $1.commits }
        let activeDays = weeklyData.filter { $0.commits > 0 }.count
        
        if activeDays > 0 {
            return Double(totalCommits) / Double(activeDays)
        } else {
            return 0.0
        }
    }
    
    var monthlyGrowthPercentage: Int {
        guard monthlyCommits.count >= 14 else { return 0 }
        
        // Split month in half for comparison: recent half vs older half
        let midPoint = monthlyCommits.count / 2
        let recentCommitCount = monthlyCommits.prefix(midPoint).reduce(0) { $0 + $1.commits }
        let olderCommitCount = monthlyCommits.dropFirst(midPoint).reduce(0) { $0 + $1.commits }
        
        guard olderCommitCount > 0 else { 
            return recentCommitCount > 0 ? 100 : 0 
        }
        
        let growth = ((Double(recentCommitCount) - Double(olderCommitCount)) / Double(olderCommitCount)) * 100
        return max(-100, min(999, Int(growth))) // Bound between -100% and 999%
    }
    
    var monthlyGrowthIsPositive: Bool {
        return monthlyGrowthPercentage >= 0
    }
    
}
