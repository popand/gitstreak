import SwiftUI

struct StreakCardView: View {
    let streak: Int
    let bestStreak: Int
    let isLoading: Bool
    
    init(streak: Int, bestStreak: Int, isLoading: Bool = false) {
        self.streak = streak
        self.bestStreak = bestStreak
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Current Streak")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 8)
            } else {
                Text("\(streak)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("days")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
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