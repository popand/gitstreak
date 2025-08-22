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
                            // Handle view all
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
                            
                            Text("Invalid token format")
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
        
        // Check if token has the correct prefix and minimum length
        // GitHub Personal Access Tokens (classic) start with "ghp_" and are 40+ characters
        // GitHub Fine-grained Personal Access Tokens start with "github_pat_" and are longer
        return (trimmedToken.hasPrefix("ghp_") && trimmedToken.count >= 40) ||
               (trimmedToken.hasPrefix("github_pat_") && trimmedToken.count >= 50)
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