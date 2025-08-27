import SwiftUI
import MessageUI

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingMailComposer = false
    @State private var expandedSection: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Getting Started Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Getting Started")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HelpItem(
                                    icon: "1.circle.fill",
                                    title: "Connect Your GitHub Account",
                                    description: "Tap the gear icon and enter your Personal Access Token to connect your GitHub account."
                                )
                                
                                HelpItem(
                                    icon: "2.circle.fill",
                                    title: "Generate a Personal Access Token",
                                    description: "Visit GitHub Settings → Developer settings → Personal access tokens → Generate new token with 'repo' and 'user' scopes."
                                )
                                
                                HelpItem(
                                    icon: "3.circle.fill",
                                    title: "View Your Stats",
                                    description: "Once connected, your commit streaks, achievements, and activity will automatically sync."
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // Frequently Asked Questions
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Frequently Asked Questions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            FAQItem(
                                question: "Why isn't my data updating?",
                                answer: "Pull down to refresh on any screen to sync with GitHub. Make sure your token has the correct permissions (repo and user scopes).",
                                isExpanded: expandedSection == "update",
                                onTap: { toggleSection("update") }
                            )
                            
                            FAQItem(
                                question: "How are streaks calculated?",
                                answer: "Streaks count consecutive days with at least one commit. The current streak shows days from your last commit, and the best streak is your longest ever.",
                                isExpanded: expandedSection == "streaks",
                                onTap: { toggleSection("streaks") }
                            )
                            
                            FAQItem(
                                question: "Is my GitHub token secure?",
                                answer: "Yes! Your token is stored securely in the iOS Keychain and is never shared with third parties. It's only used for direct GitHub API requests.",
                                isExpanded: expandedSection == "security",
                                onTap: { toggleSection("security") }
                            )
                            
                            FAQItem(
                                question: "Can I use multiple GitHub accounts?",
                                answer: "Currently, GitStreak supports one GitHub account at a time. You can disconnect and reconnect with a different account in Settings.",
                                isExpanded: expandedSection == "accounts",
                                onTap: { toggleSection("accounts") }
                            )
                            
                            FAQItem(
                                question: "What data is tracked?",
                                answer: "We track your public commits, repositories, contribution statistics, and calculate streaks. All data comes directly from GitHub's public API.",
                                isExpanded: expandedSection == "data",
                                onTap: { toggleSection("data") }
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // Troubleshooting
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Troubleshooting")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            TroubleshootItem(
                                issue: "Authentication Failed",
                                solution: "Ensure your token is valid and has 'repo' and 'user' scopes. Try generating a new token if the issue persists."
                            )
                            
                            TroubleshootItem(
                                issue: "Missing Commits",
                                solution: "GitStreak shows commits from public repositories and private repos your token has access to. Check your token permissions."
                            )
                            
                            TroubleshootItem(
                                issue: "Incorrect Statistics",
                                solution: "Pull to refresh to sync latest data. Note that GitHub's API may have delays in reporting recent activity."
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // Contact Support
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact Support")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Still need help? We're here to assist you!")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 12) {
                                // Email Support
                                Button(action: {
                                    if MFMailComposeViewController.canSendMail() {
                                        showingMailComposer = true
                                    } else {
                                        // Fallback to mailto URL
                                        if let url = URL(string: "mailto:support@gitstreak.app") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.white)
                                            .frame(width: 24)
                                        Text("Email Support")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                                
                                // GitHub Issues
                                Button(action: {
                                    if let url = URL(string: "https://github.com/popand/gitstreak/issues") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "exclamationmark.bubble.fill")
                                            .foregroundColor(.white)
                                            .frame(width: 24)
                                        Text("Report an Issue on GitHub")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // App Version Info
                    VStack(alignment: .center, spacing: 8) {
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("GitStreak v\(version) (\(build))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(
                recipients: ["support@gitstreak.app"],
                subject: "GitStreak Support Request",
                messageBody: generateSupportEmailBody()
            )
        }
    }
    
    private func toggleSection(_ section: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if expandedSection == section {
                expandedSection = nil
            } else {
                expandedSection = section
            }
        }
    }
    
    private func generateSupportEmailBody() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let device = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        
        return """
        
        
        ---
        Please describe your issue above this line
        ---
        
        App Version: \(version) (\(build))
        Device: \(device)
        iOS Version: \(osVersion)
        """
    }
}

struct HelpItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct TroubleshootItem: View {
    let issue: String
    let solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.orange)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(issue)
                        .font(.headline)
                    Text(solution)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// Mail Composer View for iOS
struct MailComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(recipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    HelpSupportView()
}