import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        Section {
                            Text("Effective Date: \(AppConstants.termsOfServiceEffectiveDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Welcome to GitStreak! These Terms of Service (\"Terms\") govern your use of our iOS application. By using GitStreak, you agree to be bound by these Terms.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("1. Acceptance of Terms")
                                .font(.headline)
                            
                            Text("By downloading, installing, or using GitStreak, you acknowledge that you have read, understood, and agree to be bound by these Terms. If you do not agree to these Terms, please do not use the app.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("2. Description of Service")
                                .font(.headline)
                            
                            Text("GitStreak is a personal productivity tool that:\n• Tracks your GitHub contribution activity\n• Displays commit streaks and statistics\n• Provides insights into your coding habits\n• Requires a valid GitHub account and Personal Access Token")
                                .font(.body)
                        }
                        
                        Section {
                            Text("3. User Requirements")
                                .font(.headline)
                            
                            Text("To use GitStreak, you must:\n• Be at least 13 years of age\n• Have a valid GitHub account\n• Generate and provide a GitHub Personal Access Token\n• Comply with GitHub's Terms of Service")
                                .font(.body)
                        }
                        
                        Section {
                            Text("4. User Responsibilities")
                                .font(.headline)
                            
                            Text("You are responsible for:\n• Maintaining the confidentiality of your GitHub token\n• All activities that occur under your account\n• Ensuring your use complies with all applicable laws\n• Not attempting to reverse engineer or hack the app")
                                .font(.body)
                        }
                    }
                    
                    Group {
                        Section {
                            Text("5. Intellectual Property")
                                .font(.headline)
                            
                            Text("GitStreak and its original content, features, and functionality are owned by the app developers and are protected by international copyright, trademark, and other intellectual property laws.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("6. Third-Party Services")
                                .font(.headline)
                            
                            Text("GitStreak integrates with GitHub's API. Your use of GitHub's services is subject to GitHub's own Terms of Service. We are not responsible for the availability or reliability of GitHub's services.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("7. Disclaimer of Warranties")
                                .font(.headline)
                            
                            Text("THE APP IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF VIRUSES OR OTHER HARMFUL COMPONENTS.")
                                .font(.body)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Section {
                            Text("8. Limitation of Liability")
                                .font(.headline)
                            
                            Text("TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATING TO YOUR USE OF THE APP.")
                                .font(.body)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Section {
                            Text("9. Indemnification")
                                .font(.headline)
                            
                            Text("You agree to indemnify and hold harmless GitStreak and its developers from any claims, losses, damages, liabilities, and expenses arising from your use of the app or violation of these Terms.")
                                .font(.body)
                        }
                    }
                    
                    Group {
                        Section {
                            Text("10. Termination")
                                .font(.headline)
                            
                            Text("We reserve the right to terminate or suspend your access to the app at any time, without prior notice, for conduct that we believe violates these Terms or is harmful to other users or the app.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("11. Changes to Terms")
                                .font(.headline)
                            
                            Text("We may modify these Terms at any time. We will notify users of any material changes by updating the \"Effective Date\" at the top. Your continued use of the app after changes constitutes acceptance of the modified Terms.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("12. Governing Law")
                                .font(.headline)
                            
                            Text("These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the app developers are located, without regard to conflict of law provisions.")
                                .font(.body)
                        }
                        
                        Section {
                            Text("13. Contact Information")
                                .font(.headline)
                            
                            Text("For questions about these Terms, please contact us through the Help & Support section in the app.")
                                .font(.body)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Terms of Service")
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
    TermsOfServiceView()
}