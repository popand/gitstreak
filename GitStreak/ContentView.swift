import SwiftUI

struct ContentView: View {
    @StateObject private var dataModel = GitStreakDataModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    HomeView(dataModel: dataModel)
                } else if selectedTab == 1 {
                    AwardsTabView(dataModel: dataModel)
                } else if selectedTab == 2 {
                    StatsView(dataModel: dataModel)
                }
                
                TabBarView(selectedTab: $selectedTab)
            }
        }
    }
}

struct HomeView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    @State private var showSettings = false
    @State private var showAllCommits = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getGreeting())
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(getSubtitle())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Current Streak
                StreakCardView(
                    streak: dataModel.currentStreak,
                    bestStreak: dataModel.bestStreak,
                    isLoading: dataModel.isLoading
                )
                .padding(.horizontal, 20)
                
                // Level Progress
                LevelProgressView(
                    level: dataModel.level,
                    levelTitle: dataModel.levelTitle,
                    xp: dataModel.xp,
                    progress: dataModel.progress,
                    xpToNext: dataModel.xpToNext
                )
                .padding(.horizontal, 20)
                
                // Weekly Activity
                WeeklyActivityView(
                    weeklyData: dataModel.weeklyData,
                    totalCommits: dataModel.totalCommitsThisWeek
                )
                .padding(.horizontal, 20)
                
                // Recent Activity Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Activity")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Spacer()
                        
                        Button("View All") {
                            showAllCommits = true
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    
                    RecentActivityView(commits: dataModel.recentCommits)
                        .padding(.horizontal, 20)
                }
                
                // Achievements Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievements")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 20)
                    
                    AchievementsView(achievements: dataModel.achievements)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(dataModel: dataModel)
        }
        .sheet(isPresented: $showAllCommits) {
            AllCommitsView(dataModel: dataModel)
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning!"
        case 12..<17: return "Good afternoon!"
        case 17..<22: return "Good evening!"
        default: return "Good night!"
        }
    }
    
    private func getSubtitle() -> String {
        let gitHubService = GitHubService.shared
        if gitHubService.isAuthenticated {
            if let username = gitHubService.username {
                return "Welcome back, @\(username)!"
            }
            return "Ready to code today?"
        } else {
            return "Connect your GitHub to get started"
        }
    }
}

// AwardsView removed - using AwardsTabView for the full awards implementation

struct StatsView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Activity Overview Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity Overview")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // Main Activity Card
                    StreakStatsCardView(dataModel: dataModel)
                    
                    // Supporting Cards
                    HStack(spacing: 16) {
                        StatCardView(
                            title: "This Week",
                            value: "\(dataModel.totalCommitsThisWeek)",
                            color: .green
                        )
                        
                        StatCardView(
                            title: "Best Streak",
                            value: "\(dataModel.bestStreak) days",
                            color: .blue
                        )
                    }
                }
                
                // Achievement Progress Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Achievement Progress")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // Achievement Summary
                    AchievementStatsCardView(dataModel: dataModel)
                    
                    // Recent Achievements
                    if !dataModel.recentlyUnlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Unlocks")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(dataModel.recentlyUnlockedAchievements.prefix(5)) { achievement in
                                        CompactAchievementCardView(achievement: achievement)
                                    }
                                }
                                .padding(.leading, 0)
                            }
                        }
                    }
                }
                
                // Personal Insights Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personal Insights")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 16) {
                        // Top row - 2 cards
                        HStack(spacing: 16) {
                            StatCardView(
                                title: "Most Active Day",
                                value: dataModel.mostActiveWeekDay.isEmpty ? "N/A" : dataModel.mostActiveWeekDay,
                                color: .blue
                            )
                            
                            StatCardView(
                                title: "Daily Average", 
                                value: dataModel.dailyCommitAverage.isFinite ? String(format: "%.1f", dataModel.dailyCommitAverage) : "N/A",
                                color: .green
                            )
                        }
                        
                        // Bottom row - 1 card centered
                        HStack(spacing: 16) {
                            StatCardView(
                                title: "Monthly Growth",
                                value: dataModel.monthlyCommits.isEmpty ? "N/A" : (dataModel.monthlyGrowthPercentage > 0 ? "+\(dataModel.monthlyGrowthPercentage)%" : "\(dataModel.monthlyGrowthPercentage)%"),
                                color: dataModel.monthlyCommits.isEmpty ? .gray : (dataModel.monthlyGrowthIsPositive ? .purple : .gray)
                            )
                            
                            // Invisible spacer card to maintain alignment
                            StatCardView(
                                title: "Total Commits", 
                                value: "\(dataModel.recentCommits.count)",
                                color: .orange
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Statistics")
    }
}

struct SettingsView: View {
    @ObservedObject var gitHubService = GitHubService.shared
    @ObservedObject var dataModel: GitStreakDataModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tokenInput = ""
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if gitHubService.isAuthenticated {
                            authenticatedView
                        } else {
                            authenticationView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var authenticatedView: some View {
        VStack(spacing: 20) {
            // Success Card with Gradient
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 8) {
                    Text("Connected to GitHub")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let username = gitHubService.username {
                        Text("@\(username)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.8, blue: 0.4),
                        Color(red: 0.3, green: 0.5, blue: 0.9),
                        Color(red: 0.6, green: 0.3, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            // Account Info Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Account Information")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        
                        Text("Username")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let username = gitHubService.username {
                            Text(username)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                            .frame(width: 28)
                        
                        Text("Status")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Authenticated")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { dataModel.refreshData() }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Refresh Data")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    gitHubService.logout()
                    dataModel.refreshData()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Disconnect Account")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.systemBackground))
                    .foregroundColor(.red)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var authenticationView: some View {
        VStack(spacing: 20) {
            // Welcome Card
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.2),
                                    Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.4),
                                    Color(red: 0.3, green: 0.5, blue: 0.9)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Connect GitHub Account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Track your real GitHub activity and streaks")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 8)
            
            // Instructions Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Setup Instructions")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach([
                        ("1", "Go to GitHub Settings → Developer Settings"),
                        ("2", "Select Personal Access Tokens → Tokens (classic)"),
                        ("3", "Generate token with 'repo' and 'user' scopes")
                    ], id: \.0) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Text(step.0)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.3, green: 0.5, blue: 0.9),
                                            Color(red: 0.6, green: 0.3, blue: 0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                            
                            Text(step.1)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            
            // Token Input Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Personal Access Token")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $tokenInput)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14, design: .monospaced))
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(tokenBorderColor, lineWidth: 1.5)
                        )
                    
                    if !tokenInput.isEmpty && !isValidGitHubToken(tokenInput) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            
                            Text("Invalid token format. Must be a valid GitHub token.")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "https://github.com/settings/tokens/new?scopes=repo,user&description=GitStreak%20App") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "safari")
                            .font(.system(size: 12))
                        
                        Text("Generate Token on GitHub")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Connect Button
            Button(action: authenticateWithToken) {
                HStack(spacing: 8) {
                    if isAuthenticating {
                        ProgressView()
                            .scaleEffect(0.9)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(isAuthenticating ? "Connecting..." : "Connect Account")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(connectButtonBackground)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: connectButtonShadowColor, radius: 8, x: 0, y: 4)
            }
            .disabled(tokenInput.isEmpty || isAuthenticating || !isValidGitHubToken(tokenInput))
        }
    }
    
    private func authenticateWithToken() {
        let trimmedToken = tokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty && isValidGitHubToken(trimmedToken) else { return }
        
        isAuthenticating = true
        
        Task {
            do {
                try await gitHubService.authenticate(token: trimmedToken)
                await MainActor.run {
                    dataModel.refreshData()
                    tokenInput = ""
                    isAuthenticating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isAuthenticating = false
                }
            }
        }
    }
    
    private func isValidGitHubToken(_ token: String) -> Bool {
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Enhanced validation using regex patterns for GitHub tokens
        // GitHub Personal Access Tokens (classic): ghp_ + 36+ alphanumeric characters
        // GitHub Fine-grained Personal Access Tokens: github_pat_ + 50+ alphanumeric/underscore characters
        let classicTokenPattern = "^ghp_[A-Za-z0-9]{36,}$"
        let fineGrainedTokenPattern = "^github_pat_[A-Za-z0-9_]{50,}$"
        
        guard !trimmedToken.isEmpty else { return false }
        
        // Use NSRegularExpression for secure pattern matching
        do {
            let classicRegex = try NSRegularExpression(pattern: classicTokenPattern)
            let fineGrainedRegex = try NSRegularExpression(pattern: fineGrainedTokenPattern)
            
            let range = NSRange(location: 0, length: trimmedToken.utf16.count)
            
            let matchesClassic = classicRegex.firstMatch(in: trimmedToken, range: range) != nil
            let matchesFineGrained = fineGrainedRegex.firstMatch(in: trimmedToken, range: range) != nil
            
            return matchesClassic || matchesFineGrained
        } catch {
            // If regex compilation fails, fall back to basic validation as a safety measure
            return (trimmedToken.hasPrefix("ghp_") && trimmedToken.count >= 40) ||
                   (trimmedToken.hasPrefix("github_pat_") && trimmedToken.count >= 50)
        }
    }
    
    private var tokenBorderColor: Color {
        if tokenInput.isEmpty {
            return Color(.systemGray4)
        } else if isValidGitHubToken(tokenInput) {
            return Color.green.opacity(0.5)
        } else {
            return Color.red.opacity(0.5)
        }
    }
    
    private var connectButtonBackground: some View {
        Group {
            if tokenInput.isEmpty || !isValidGitHubToken(tokenInput) {
                Color.gray.opacity(0.3)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.8, blue: 0.4),
                        Color(red: 0.3, green: 0.5, blue: 0.9)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
    
    private var connectButtonShadowColor: Color {
        if tokenInput.isEmpty || !isValidGitHubToken(tokenInput) {
            return Color.clear
        } else {
            return Color.blue.opacity(0.3)
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Awards Tab Implementation

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

// MARK: - Custom Components for Stats

struct StreakStatsCardView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Status")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text("\(dataModel.currentStreak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("day streak")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 8)
                }
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Commits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(dataModel.totalCommitsThisWeek)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 4) {
                        Text("Level \(dataModel.level)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("(\(Int(dataModel.progress * 100))%)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(
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
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct AchievementStatsCardView: View {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievements")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(dataModel.unlockedAchievementCount)/\(totalAchievements)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Bonus XP")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(dataModel.totalAchievementXP)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            
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
                
                ProgressView(value: milestoneProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.blue)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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


// MARK: - Shared Components

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
    @ObservedObject var dataModel: GitStreakDataModel
    
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

struct SimpleAchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // Achievement Icon
            Text(achievement.icon)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(achievement.unlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Status Badge
                if achievement.unlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("UNLOCKED")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "lock")
                            .font(.system(size: 10, weight: .bold))
                        Text("LOCKED")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(achievement.unlocked ? Color(.systemBackground) : Color.gray.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    achievement.unlocked ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.4),
                            Color(red: 0.3, green: 0.5, blue: 0.9),
                            Color(red: 0.6, green: 0.3, blue: 0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                    lineWidth: achievement.unlocked ? 2 : 0
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
