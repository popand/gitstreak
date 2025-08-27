import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        Section {
                            Text("Last Updated: \(AppConstants.privacyPolicyLastUpdated)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("GitStreak (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our iOS application.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Information We Collect")
                                .font(.headline)
                            
                            Text("**GitHub Personal Access Token**")
                                .font(.subheadline)
                                .padding(.top, 8)
                            
                            Text("• We collect and securely store your GitHub Personal Access Token in the iOS Keychain\n• This token is used solely to authenticate with GitHub's API\n• The token never leaves your device except for authorized GitHub API requests\n• We never transmit your token to our servers or any third parties")
                                .font(.body)
                                .padding(.leading, 16)
                            
                            Text("**GitHub Activity Data**")
                                .font(.subheadline)
                                .padding(.top, 8)
                            
                            Text("• We fetch your public GitHub activity including commits, repositories, and contribution statistics\n• This data is retrieved directly from GitHub's API\n• All data is processed and stored locally on your device\n• We do not collect or store this data on external servers")
                                .font(.body)
                                .padding(.leading, 16)
                        }
                        
                        Section {
                            Text("How We Use Your Information")
                                .font(.headline)
                            
                            Text("Your information is used exclusively to:\n• Display your GitHub contribution statistics\n• Calculate your commit streaks and achievements\n• Show your recent activity and repository information\n• Provide personalized insights about your coding habits")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Data Storage and Security")
                                .font(.headline)
                            
                            Text("• All sensitive data (tokens) are stored in the iOS Keychain with encryption\n• GitHub activity data is cached locally on your device\n• We implement industry-standard security measures\n• We do not operate external servers or databases that store your data")
                                .font(.body)
                        }
                    }
                    
                    Group {
                        Section {
                            Text("Data Sharing")
                                .font(.headline)
                            
                            Text("We do not sell, trade, or otherwise transfer your personal information to third parties. Your GitHub token and activity data remain exclusively on your device and are only used for direct communication with GitHub's API.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Your Rights")
                                .font(.headline)
                            
                            Text("You have the right to:\n• Disconnect your GitHub account at any time\n• Delete all stored data by removing the app\n• Request information about data we've stored\n• Control what GitHub data is accessible via token scopes")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Children's Privacy")
                                .font(.headline)
                            
                            Text("Our service is not directed to individuals under the age of 13. We do not knowingly collect personal information from children under 13.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Changes to This Policy")
                                .font(.headline)
                            
                            Text("We may update our Privacy Policy from time to time. We will notify you of any changes by updating the \"Last Updated\" date at the top of this policy.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("Contact Us")
                                .font(.headline)
                            
                            Text("If you have questions about this Privacy Policy, please contact us through the Help & Support section in the app.")
                                .font(.body)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}