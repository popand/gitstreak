import SwiftUI

struct WeeklyActivityView: View {
    let weeklyData: [WeeklyData]
    let totalCommits: Int
    
    var maxCommits: Int {
        weeklyData.map { $0.commits }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(weeklyData) { day in
                    VStack(spacing: 6) {
                        Spacer(minLength: 0)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                day.active ? 
                                Color(red: 0.2, green: 0.8, blue: 0.4) : 
                                Color(.systemGray5)
                            )
                            .frame(height: max(
                                CGFloat(day.commits) / CGFloat(maxCommits) * 96, // Use fixed height calculation
                                8
                            ))
                        
                        Text(day.day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(.vertical, 20)
    }
}