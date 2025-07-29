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
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    
                    Text("\(streak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text("Day Streak")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("Your best: \(bestStreak) days")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}