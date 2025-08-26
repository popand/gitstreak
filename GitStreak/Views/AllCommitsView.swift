import SwiftUI

struct AllCommitsView: View {
    @ObservedObject var dataModel: GitStreakDataModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
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
                                
                                Text("\(dataModel.monthlyCommits.count) commits")
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
                        
                        // Commits List
                        VStack(spacing: 0) {
                            ForEach(dataModel.monthlyCommits) { commit in
                                CommitRowView(commit: commit)
                                
                                if commit.id != dataModel.monthlyCommits.last?.id {
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
    }
}

struct CommitRowView: View {
    let commit: CommitData
    
    var body: some View {
        HStack(spacing: 16) {
            // Commit icon with gradient background
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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