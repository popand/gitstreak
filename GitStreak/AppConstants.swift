import Foundation

struct AppConstants {
    // MARK: - Legal Document Dates
    static let privacyPolicyLastUpdated = "August 27, 2025"
    static let termsOfServiceEffectiveDate = "August 27, 2025"
    
    // MARK: - Contact Information
    static let supportEmail = "gitstreakapp@gmail.com"
    
    // MARK: - External URLs
    static let githubIssuesURL = "https://github.com/popand/gitstreak/issues"
    static let githubTokenGenerationURL = "https://github.com/settings/tokens/new?scopes=repo,user&description=GitStreak%20App"
    
    // MARK: - App Information
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}