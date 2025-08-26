import SwiftUI

// MARK: - Placeholder AchievementsView (deprecated - use AwardsTabView instead)
struct AchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        Text("This view has been replaced by AwardsTabView")
            .foregroundColor(.secondary)
            .padding()
    }
}