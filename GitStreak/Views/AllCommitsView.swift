import SwiftUI

struct AllCommitsView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    @Environment(\.dismiss) private var dismiss
    
    private var commitCountText: String {
        let count = dataModel.monthlyCommits.count
        return "\(count) \(count == 1 ? "commit" : "commits")"
    }
    
    var body: some View {
        NavigationView {
            commitListView
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures single column on all devices
    }
    
    private var commitListView: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if dataModel.isLoading {
                loadingStateView
            } else if let errorMessage = dataModel.errorMessage {
                errorStateView(errorMessage)
            } else if dataModel.monthlyCommits.isEmpty {
                emptyStateView
            } else {
                commitsContentView
            }
        }
        .navigationTitle("All Commits")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private var loadingStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Loading commits...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Fetching your recent activity")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Commits Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("You haven't made any commits in the last 30 days.\nStart coding to see your activity here!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            Button(action: {
                dataModel.refreshData()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Refresh")
                        .fontWeight(.semibold)
                }
                .frame(minWidth: 120)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func errorStateView(_ errorMessage: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.2), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.red, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("Failed to Load Commits")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    dataModel.refreshData()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Try Again")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 120)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Go Back")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var commitsContentView: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: []) {
                // Monthly Summary Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Last 30 Days")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(commitCountText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Commits List - Using LazyVStack for better performance
                LazyVStack(spacing: 0) {
                    ForEach(Array(dataModel.monthlyCommits.enumerated()), id: \.element.id) { index, commit in
                        CommitRowView(commit: commit)
                        
                        if index < dataModel.monthlyCommits.count - 1 {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

struct CommitRowView: View {
    let commit: CommitData
    
    // Pre-define gradient for better performance
    private let iconGradient = LinearGradient(
        colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        HStack(spacing: 16) {
            // Commit icon with gradient background
            ZStack {
                Circle()
                    .fill(iconGradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(commit.repo)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(commit.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    if let additions = commit.additions {
                        Label("\(additions)", systemImage: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if let deletions = commit.deletions {
                        Label("\(deletions)", systemImage: "minus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Text(commit.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    AllCommitsView(dataModel: GitStreakDataModel())
}