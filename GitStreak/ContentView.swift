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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good morning!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Ready to code today?")
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
                        
                        Button(action: {}) {
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
                    bestStreak: dataModel.bestStreak
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

#Preview {
    ContentView()
}