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
                    AwardsView(dataModel: dataModel)
                } else if selectedTab == 2 {
                    StatsView(dataModel: dataModel)
                } else {
                    SocialView(dataModel: dataModel)
                }
                
                TabBarView(selectedTab: $selectedTab)
            }
        }
    }
}

struct HomeView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Current Streak
                StreakCardView(
                    streak: dataModel.currentStreak,
                    bestStreak: dataModel.bestStreak,
                    isLoading: dataModel.isLoading
                )
                .padding(.horizontal, 24)
                
                // Level Progress
                LevelProgressView(
                    level: dataModel.level,
                    levelTitle: dataModel.levelTitle,
                    xp: dataModel.xp,
                    progress: dataModel.progress,
                    xpToNext: dataModel.xpToNext
                )
                .padding(.horizontal, 24)
                
                // This Week Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("This Week")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                    
                    WeeklyActivityView(
                        weeklyData: dataModel.weeklyData,
                        totalCommits: dataModel.totalCommitsThisWeek
                    )
                    .padding(.horizontal, 24)
                }
                
                // Recent Activity Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Activity")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("View All") {
                            // Handle view all
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 24)
                    
                    RecentActivityView(commits: dataModel.recentCommits)
                        .padding(.horizontal, 24)
                }
                
                // Achievements Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Achievements")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                    
                    AchievementsView(achievements: dataModel.achievements)
                        .padding(.horizontal, 24)
                }
                
                // Quick Actions
                HStack(spacing: 16) {
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Log Commit")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Set Goal")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(dataModel: dataModel)
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

struct AwardsView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    var body: some View {
        VStack {
            Text("Awards")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Text("Coming Soon")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct StatsView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    var body: some View {
        VStack {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Text("Coming Soon")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct SocialView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    
    var body: some View {
        VStack {
            Text("Social")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Text("Coming Soon")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
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
            VStack(spacing: 24) {
                if gitHubService.isAuthenticated {
                    authenticatedView
                } else {
                    authenticationView
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Connected to GitHub")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let username = gitHubService.username {
                    Text("@\(username)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 24)
            
            VStack(spacing: 16) {
                Button("Refresh Data") {
                    dataModel.refreshData()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
                
                Button("Disconnect Account") {
                    gitHubService.logout()
                    dataModel.refreshData()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
                .fontWeight(.semibold)
            }
        }
    }
    
    private var authenticationView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Connect GitHub Account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Track your real GitHub activity and streaks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("GitHub Personal Access Token")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("1. Go to GitHub Settings → Developer Settings → Personal Access Tokens")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("2. Generate a new token with 'repo' and 'user' scopes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("3. Paste your token below:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $tokenInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                
                if !tokenInput.isEmpty && !isValidGitHubToken(tokenInput) {
                    Text("Invalid token format. Must start with 'ghp_' (40+ chars) or 'github_pat_' (50+ chars)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                }
                
                Button("Generate Token on GitHub") {
                    if let url = URL(string: "https://github.com/settings/tokens/new?scopes=repo,user&description=GitStreak%20App") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Button(action: authenticateWithToken) {
                HStack {
                    if isAuthenticating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }
                    
                    Text(isAuthenticating ? "Connecting..." : "Connect Account")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
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
        
        // Check if token has the correct prefix and minimum length
        // GitHub Personal Access Tokens (classic) start with "ghp_" and are 40+ characters
        // GitHub Fine-grained Personal Access Tokens start with "github_pat_" and are longer
        return (trimmedToken.hasPrefix("ghp_") && trimmedToken.count >= 40) ||
               (trimmedToken.hasPrefix("github_pat_") && trimmedToken.count >= 50)
    }
    
    private var buttonBackgroundColor: Color {
        if tokenInput.isEmpty {
            return Color.gray
        } else if isValidGitHubToken(tokenInput) {
            return Color.blue
        } else {
            return Color.red.opacity(0.6)
        }
    }
}

#Preview {
    ContentView()
}