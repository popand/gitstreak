import SwiftUI

struct RecentActivityView: View {
    let commits: [CommitData]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(commits) { commit in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.branch")
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .font(.system(size: 14))
                        )
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(commit.repo)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(commit.message)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        HStack(spacing: 12) {
                            Text(commit.time)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.8))
                            
                            Text("\(commit.commits) commit\(commit.commits > 1 ? "s" : "")")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        }
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
        }
    }
}