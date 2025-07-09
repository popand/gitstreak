import SwiftUI

struct RecentActivityView: View {
    let commits: [CommitData]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(commits) { commit in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "arrow.branch")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(commit.repo)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(commit.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        HStack(spacing: 16) {
                            Text(commit.time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(commit.commits) commit\(commit.commits > 1 ? "s" : "")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
}