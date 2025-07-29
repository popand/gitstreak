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
        
        guard let url = URL(string: "\(baseURL)/search/commits?q=author:\(username)&sort=committer-date&order=desc&per_page=100") else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let searchResult = try JSONDecoder().decode(GitHubCommitSearchResult.self, from: data)
        return searchResult.items
    }
    
    func fetchContributionStats() async throws -> ContributionStats {
        guard let username = username else {
            throw GitHubError.notAuthenticated
        }
        
        let commits = try await fetchUserCommits()
        
        var weeklyCommits: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        for commit in commits {
            if let date = dateFormatter.date(from: commit.commit.committer.date) {
                let dayKey = dayFormatter.string(from: date)
                weeklyCommits[dayKey, default: 0] += 1
            }
        }
        
        let currentStreak = calculateCurrentStreak(commits: commits)
        let bestStreak = calculateBestStreak(commits: commits)
        
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
            }
        )
    }
    
    private func calculateCurrentStreak(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        // Parse commit dates and convert to local timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
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
            currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay) ?? break
        }
        
        return streak
    }
    
    private func calculateBestStreak(commits: [GitHubCommit]) -> Int {
        guard !commits.isEmpty else { return 0 }
        
        // Parse commit dates and convert to local timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        guard let date = formatter.date(from: dateString) else {
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
}

struct CommitDetail: Codable {
    let message: String
    let committer: Committer
}

struct Committer: Codable {
    let date: String
}

struct Repository: Codable {
    let name: String
}

struct GitHubCommitSearchResult: Codable {
    let items: [GitHubCommit]
}

struct ContributionStats {
    let currentStreak: Int
    let bestStreak: Int
    let weeklyCommits: [String: Int]
    let recentCommits: [CommitData]
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
        Achievement(title: "First Commit", description: "Make your first commit", icon: "🌱", unlocked: false),
        Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: false),
        Achievement(title: "Early Bird", description: "Commit before 9 AM", icon: "🌅", unlocked: false),
        Achievement(title: "Night Owl", description: "Commit after 10 PM", icon: "🦉", unlocked: false)
    ]
    
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
        
        weeklyData = [
            WeeklyData(day: "Mon", commits: 4, active: true),
            WeeklyData(day: "Tue", commits: 2, active: true),
            WeeklyData(day: "Wed", commits: 6, active: true),
            WeeklyData(day: "Thu", commits: 3, active: true),
            WeeklyData(day: "Fri", commits: 5, active: true),
            WeeklyData(day: "Sat", commits: 1, active: true),
            WeeklyData(day: "Sun", commits: 7, active: true)
        ]
        
        achievements[0] = Achievement(title: "First Commit", description: "Make your first commit", icon: "🌱", unlocked: true)
        achievements[1] = Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: true)
        achievements[2] = Achievement(title: "Early Bird", description: "Commit before 9 AM", icon: "🌅", unlocked: true)
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
        achievements[0] = Achievement(title: "First Commit", description: "Make your first commit", icon: "🌱", unlocked: !recentCommits.isEmpty)
        achievements[1] = Achievement(title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: currentStreak >= 7)
    }
    
    func refreshData() {
        if gitHubService.isAuthenticated {
            loadGitHubData()
        } else {
            loadMockData()
        }
    }
}