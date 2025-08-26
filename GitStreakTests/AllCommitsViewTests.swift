import XCTest
import SwiftUI
@testable import GitStreak

class AllCommitsViewTests: XCTestCase {
    
    var dataModel: GitStreakDataModel!
    
    override func setUp() {
        super.setUp()
        dataModel = GitStreakDataModel()
    }
    
    override func tearDown() {
        dataModel = nil
        super.tearDown()
    }
    
    // MARK: - AllCommitsView Basic Tests
    
    func testAllCommitsViewInstantiation() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        XCTAssertNotNil(allCommitsView, "AllCommitsView should be instantiable")
        
        let body = allCommitsView.body
        XCTAssertNotNil(body, "AllCommitsView should have a body")
    }
    
    func testCommitCountTextSingular() {
        // Create data model with single commit
        dataModel.monthlyCommits = [
            CommitData(repo: "test-repo", message: "Single commit", time: "1h ago", commits: 1)
        ]
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let countText = allCommitsView.commitCountText
        
        XCTAssertEqual(countText, "1 commit", "Should show singular 'commit' for single commit")
    }
    
    func testCommitCountTextPlural() {
        // Create data model with multiple commits
        dataModel.monthlyCommits = [
            CommitData(repo: "test-repo1", message: "First commit", time: "1h ago", commits: 1),
            CommitData(repo: "test-repo2", message: "Second commit", time: "2h ago", commits: 1),
            CommitData(repo: "test-repo3", message: "Third commit", time: "3h ago", commits: 1)
        ]
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let countText = allCommitsView.commitCountText
        
        XCTAssertEqual(countText, "3 commits", "Should show plural 'commits' for multiple commits")
    }
    
    func testCommitCountTextZero() {
        // Create data model with no commits
        dataModel.monthlyCommits = []
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let countText = allCommitsView.commitCountText
        
        XCTAssertEqual(countText, "0 commits", "Should show '0 commits' for empty array")
    }
    
    // MARK: - Data Formatting Function Tests
    
    func testFormatLargeNumberSmall() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        XCTAssertEqual(allCommitsView.formatLargeNumber(5), "5")
        XCTAssertEqual(allCommitsView.formatLargeNumber(99), "99")
        XCTAssertEqual(allCommitsView.formatLargeNumber(567), "567")
        XCTAssertEqual(allCommitsView.formatLargeNumber(999), "999")
    }
    
    func testFormatLargeNumberThousands() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        XCTAssertEqual(allCommitsView.formatLargeNumber(1000), "1.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1500), "1.5K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(2500), "2.5K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(15000), "15.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(999999), "1000.0K")
    }
    
    func testFormatLargeNumberMillions() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        XCTAssertEqual(allCommitsView.formatLargeNumber(1000000), "1.0M")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1500000), "1.5M")
        XCTAssertEqual(allCommitsView.formatLargeNumber(2500000), "2.5M")
        XCTAssertEqual(allCommitsView.formatLargeNumber(15000000), "15.0M")
    }
    
    func testFormatLargeNumberEdgeCases() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        XCTAssertEqual(allCommitsView.formatLargeNumber(0), "0")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1), "1")
        XCTAssertEqual(allCommitsView.formatLargeNumber(999), "999")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1001), "1.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(999999), "1000.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1000001), "1.0M")
    }
    
    // MARK: - Message Sanitization Tests
    
    func testSanitizeCommitMessageBasic() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let cleanMessage = "Simple commit message"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(cleanMessage), cleanMessage)
    }
    
    func testSanitizeCommitMessageWhitespace() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let messageWithWhitespace = "  Message with whitespace  "
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithWhitespace), "Message with whitespace")
        
        let messageWithTabs = "Message\twith\ttabs"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithTabs), "Message with tabs")
        
        let messageWithDoubleSpaces = "Message  with  double  spaces"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithDoubleSpaces), "Message with double spaces")
    }
    
    func testSanitizeCommitMessageNewlines() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let messageWithNewlines = "First line\nSecond line\nThird line"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithNewlines), "First line Second line Third line")
        
        let messageWithCarriageReturns = "First line\rSecond line\rThird line"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithCarriageReturns), "First line Second line Third line")
        
        let messageWithMixed = "First line\n\rSecond\tline\n\rThird line"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(messageWithMixed), "First line Second line Third line")
    }
    
    func testSanitizeCommitMessageLength() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let longMessage = String(repeating: "A", count: 250)
        let sanitized = allCommitsView.sanitizeCommitMessage(longMessage)
        XCTAssertEqual(sanitized.count, 200, "Should truncate to 200 characters")
        XCTAssertTrue(sanitized.allSatisfy { $0 == "A" }, "Should preserve all 'A' characters up to limit")
    }
    
    func testSanitizeCommitMessageComplex() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let complexMessage = "\t  Major refactoring:\n- Updated all legacy components\n- Added new TypeScript definitions\n\r- Fixed multiple performance issues\n\t\t- Updated documentation  "
        
        let expected = "Major refactoring: - Updated all legacy components - Added new TypeScript definitions - Fixed multiple performance issues - Updated documentation"
        XCTAssertEqual(allCommitsView.sanitizeCommitMessage(complexMessage), expected)
    }
    
    // MARK: - CommitRowView Tests
    
    func testCommitRowViewBasic() {
        let commit = CommitData(
            repo: "test-repo",
            message: "Test commit message",
            time: "2h ago",
            commits: 1,
            additions: 50,
            deletions: 20
        )
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let commitRowView = CommitRowView(
            commit: commit,
            formatNumber: allCommitsView.formatLargeNumber,
            sanitizeMessage: allCommitsView.sanitizeCommitMessage
        )
        
        XCTAssertNotNil(commitRowView, "CommitRowView should be instantiable")
        
        let body = commitRowView.body
        XCTAssertNotNil(body, "CommitRowView should have a body")
    }
    
    func testCommitRowViewWithLargeNumbers() {
        let commit = CommitData(
            repo: "big-refactor",
            message: "Major code refactoring",
            time: "1d ago",
            commits: 1,
            additions: 15000,
            deletions: 8500
        )
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let commitRowView = CommitRowView(
            commit: commit,
            formatNumber: allCommitsView.formatLargeNumber,
            sanitizeMessage: allCommitsView.sanitizeCommitMessage
        )
        
        XCTAssertNotNil(commitRowView, "Should handle large numbers")
        
        // Test that formatting functions work correctly
        XCTAssertEqual(allCommitsView.formatLargeNumber(commit.additions!), "15.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(commit.deletions!), "8.5K")
    }
    
    func testCommitRowViewWithNilValues() {
        let commit = CommitData(
            repo: "test-repo",
            message: "Test commit without stats",
            time: "3h ago",
            commits: 1,
            additions: nil,
            deletions: nil
        )
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let commitRowView = CommitRowView(
            commit: commit,
            formatNumber: allCommitsView.formatLargeNumber,
            sanitizeMessage: allCommitsView.sanitizeCommitMessage
        )
        
        XCTAssertNotNil(commitRowView, "Should handle nil additions/deletions")
    }
    
    func testCommitRowViewWithZeroValues() {
        let commit = CommitData(
            repo: "test-repo",
            message: "Commit with zero changes",
            time: "1h ago",
            commits: 1,
            additions: 0,
            deletions: 0
        )
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let commitRowView = CommitRowView(
            commit: commit,
            formatNumber: allCommitsView.formatLargeNumber,
            sanitizeMessage: allCommitsView.sanitizeCommitMessage
        )
        
        XCTAssertNotNil(commitRowView, "Should handle zero values")
    }
    
    func testCommitRowViewWithDirtyMessage() {
        let commit = CommitData(
            repo: "test-repo",
            message: "  Messy commit message\n\nWith newlines\tand tabs  ",
            time: "4h ago",
            commits: 1,
            additions: 100,
            deletions: 50
        )
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        let sanitized = allCommitsView.sanitizeCommitMessage(commit.message)
        
        XCTAssertEqual(sanitized, "Messy commit message With newlines and tabs")
        
        let commitRowView = CommitRowView(
            commit: commit,
            formatNumber: allCommitsView.formatLargeNumber,
            sanitizeMessage: allCommitsView.sanitizeCommitMessage
        )
        
        XCTAssertNotNil(commitRowView, "Should handle dirty commit messages")
    }
    
    // MARK: - View State Tests
    
    func testAllCommitsViewWithLoadingState() {
        dataModel.isLoading = true
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = []
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "Should handle loading state")
    }
    
    func testAllCommitsViewWithErrorState() {
        dataModel.isLoading = false
        dataModel.errorMessage = "Failed to fetch commits"
        dataModel.monthlyCommits = []
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "Should handle error state")
    }
    
    func testAllCommitsViewWithEmptyState() {
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = []
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "Should handle empty state")
    }
    
    func testAllCommitsViewWithContentState() {
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = [
            CommitData(repo: "test-repo", message: "Test commit", time: "1h ago", commits: 1, additions: 50, deletions: 20)
        ]
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "Should handle content state")
    }
    
    // MARK: - Edge Cases and Performance Tests
    
    func testAllCommitsViewWithManyCommits() {
        // Create a large number of commits to test performance
        var commits: [CommitData] = []
        for i in 0..<100 {
            commits.append(CommitData(
                repo: "repo-\(i)",
                message: "Commit number \(i)",
                time: "\(i)h ago",
                commits: 1,
                additions: Int.random(in: 1...1000),
                deletions: Int.random(in: 1...500)
            ))
        }
        
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = commits
        
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "Should handle many commits efficiently")
        
        let countText = allCommitsView.commitCountText
        XCTAssertEqual(countText, "100 commits", "Should correctly count many commits")
    }
    
    func testFormattingFunctionPerformance() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Test formatting performance with many calls
        measure {
            for _ in 0..<1000 {
                _ = allCommitsView.formatLargeNumber(Int.random(in: 1...10000000))
            }
        }
    }
    
    func testSanitizationPerformance() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let testMessages = [
            "Simple message",
            "Message\nwith\nnewlines",
            "  Message  with  whitespace  ",
            String(repeating: "Long message ", count: 50),
            "Complex\n\rmessage\twith\tall\ttypes\nof\rwhitespace"
        ]
        
        // Test sanitization performance
        measure {
            for _ in 0..<1000 {
                for message in testMessages {
                    _ = allCommitsView.sanitizeCommitMessage(message)
                }
            }
        }
    }
}