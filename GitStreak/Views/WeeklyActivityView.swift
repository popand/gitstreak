import SwiftUI

struct WeeklyActivityView: View {
    let weeklyData: [WeeklyData]
    let totalCommits: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Activity")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(totalCommits) commits")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData) { day in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 32, height: 100)
                            
                            Rectangle()
                                .fill(day.active ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 32, height: max(CGFloat(day.commits) * 8, 16))
                                .cornerRadius(4)
                        }
                        
                        Text(day.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}