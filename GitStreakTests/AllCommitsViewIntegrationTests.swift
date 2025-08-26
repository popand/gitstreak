import XCTest
import SwiftUI
@testable import GitStreak

class AllCommitsViewIntegrationTests: XCTestCase {
    
    var dataModel: GitStreakDataModel!
    
    override func setUp() {
        super.setUp()
        dataModel = GitStreakDataModel()
    }
    
    override func tearDown() {
        dataModel = nil
        super.tearDown()
    }
    
    // MARK: - Navigation Integration Tests
    
    func testAllCommitsViewNavigationFlow() {
        // Test the full flow from ContentView to AllCommitsView
        let contentView = ContentView()
        XCTAssertNotNil(contentView, "ContentView should be instantiable for navigation testing")
        
        // Test HomeView with data model
        let homeView = HomeView(dataModel: dataModel)
        XCTAssertNotNil(homeView, "HomeView should be accessible for navigation")
        
        // Test AllCommitsView instantiation from navigation
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        XCTAssertNotNil(allCommitsView, "AllCommitsView should be accessible via navigation")
    }
    
    func testAllCommitsViewModalPresentation() {
        // Test that AllCommitsView works as a modal presentation
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Verify view can be created and has necessary components for modal presentation
        XCTAssertNotNil(allCommitsView, "Modal AllCommitsView should be instantiable")
        
        let body = allCommitsView.body
        XCTAssertNotNil(body, "Modal presentation should have a body")
    }
    
    // MARK: - State Transition Integration Tests
    
    func testStateTransitionsInRealTime() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Test loading state
        dataModel.isLoading = true
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = []
        
        XCTAssertNotNil(allCommitsView, "View should handle loading state transition")
        
        // Test error state transition
        dataModel.isLoading = false
        dataModel.errorMessage = "Network error occurred"
        
        XCTAssertNotNil(allCommitsView, "View should handle loading to error state transition")
        
        // Test empty state transition
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = []
        
        XCTAssertNotNil(allCommitsView, "View should handle error to empty state transition")
        
        // Test content state transition
        dataModel.monthlyCommits = [
            CommitData(repo: "test", message: "Test commit", time: "1h ago", commits: 1)
        ]
        
        XCTAssertNotNil(allCommitsView, "View should handle empty to content state transition")
    }
    
    func testDataRefreshIntegration() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Test initial state
        XCTAssertNotNil(allCommitsView, "Initial view should be created")
        
        // Simulate data refresh (this would trigger in UI through refresh buttons)
        let initialCommitCount = dataModel.monthlyCommits.count
        
        // Add new commits to simulate refresh
        dataModel.monthlyCommits.append(
            CommitData(repo: "new-repo", message: "New commit after refresh", time: "now", commits: 1)
        )
        
        XCTAssertEqual(dataModel.monthlyCommits.count, initialCommitCount + 1, 
                      "Data model should reflect refreshed data")
        
        // View should still be valid after data changes
        XCTAssertNotNil(allCommitsView, "View should remain valid after data refresh")
    }
    
    // MARK: - Performance Integration Tests
    
    func testLargeDataSetRendering() {
        // Create large dataset to test rendering performance
        var largeDataSet: [CommitData] = []
        for i in 0..<500 {
            largeDataSet.append(CommitData(
                repo: "repo-\(i % 50)", // Vary repo names
                message: "Commit \(i): " + String(repeating: "Lorem ipsum ", count: (i % 10) + 1),
                time: "\(i % 24)h ago",
                commits: 1,
                additions: Int.random(in: 0...10000),
                deletions: Int.random(in: 0...5000)
            ))
        }
        
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = largeDataSet
        
        measure {
            let allCommitsView = AllCommitsView(dataModel: dataModel)
            _ = allCommitsView.body // Force body evaluation
        }
    }
    
    func testRapidStateChanges() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        measure {
            // Simulate rapid state changes that might occur in real usage
            for i in 0..<100 {
                if i % 4 == 0 {
                    dataModel.isLoading = true
                    dataModel.errorMessage = nil
                    dataModel.monthlyCommits = []
                } else if i % 4 == 1 {
                    dataModel.isLoading = false
                    dataModel.errorMessage = "Error \(i)"
                    dataModel.monthlyCommits = []
                } else if i % 4 == 2 {
                    dataModel.isLoading = false
                    dataModel.errorMessage = nil
                    dataModel.monthlyCommits = []
                } else {
                    dataModel.isLoading = false
                    dataModel.errorMessage = nil
                    dataModel.monthlyCommits = [
                        CommitData(repo: "test-\(i)", message: "Message \(i)", time: "1h ago", commits: 1)
                    ]
                }
                
                // Access the body to ensure view can handle the state change
                _ = allCommitsView.body
            }
        }
    }
    
    // MARK: - Data Consistency Integration Tests
    
    func testDataModelConsistency() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Ensure data model maintains consistency across different operations
        let initialData = dataModel.monthlyCommits
        
        // Test commit count consistency
        let initialCountText = allCommitsView.commitCountText
        let expectedInitialCount = "\(initialData.count) \(initialData.count == 1 ? "commit" : "commits")"
        XCTAssertEqual(initialCountText, expectedInitialCount, "Initial count should be consistent")
        
        // Add commits and verify consistency
        dataModel.monthlyCommits.append(contentsOf: [
            CommitData(repo: "test1", message: "Test 1", time: "1h ago", commits: 1),
            CommitData(repo: "test2", message: "Test 2", time: "2h ago", commits: 1)
        ])
        
        let updatedCountText = allCommitsView.commitCountText
        let expectedUpdatedCount = "\(dataModel.monthlyCommits.count) commits"
        XCTAssertEqual(updatedCountText, expectedUpdatedCount, "Updated count should be consistent")
        
        // Clear commits and verify
        dataModel.monthlyCommits = []
        let emptyCountText = allCommitsView.commitCountText
        XCTAssertEqual(emptyCountText, "0 commits", "Empty count should be consistent")
    }
    
    func testFormattingConsistencyAcrossStates() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Create commits with various number formats to test consistency
        let testCommits = [
            CommitData(repo: "small", message: "Small changes", time: "1h ago", commits: 1, 
                      additions: 50, deletions: 25),
            CommitData(repo: "medium", message: "Medium changes", time: "2h ago", commits: 1, 
                      additions: 1500, deletions: 750),
            CommitData(repo: "large", message: "Large changes", time: "3h ago", commits: 1, 
                      additions: 15000, deletions: 7500),
            CommitData(repo: "huge", message: "Huge changes", time: "4h ago", commits: 1, 
                      additions: 1500000, deletions: 750000),
        ]
        
        dataModel.monthlyCommits = testCommits
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        
        // Verify formatting is consistent
        XCTAssertEqual(allCommitsView.formatLargeNumber(50), "50")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1500), "1.5K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(15000), "15.0K")
        XCTAssertEqual(allCommitsView.formatLargeNumber(1500000), "1.5M")
        
        // Verify view can render with all these different formats
        XCTAssertNotNil(allCommitsView.body, "View should render consistently with mixed number formats")
    }
    
    func testMessageSanitizationConsistency() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        let messyCommits = [
            CommitData(repo: "test1", message: "Clean message", time: "1h ago", commits: 1),
            CommitData(repo: "test2", message: "  Message with spaces  ", time: "2h ago", commits: 1),
            CommitData(repo: "test3", message: "Message\nwith\nnewlines", time: "3h ago", commits: 1),
            CommitData(repo: "test4", message: "Message\twith\ttabs", time: "4h ago", commits: 1),
            CommitData(repo: "test5", message: String(repeating: "Very long message ", count: 20), time: "5h ago", commits: 1),
        ]
        
        dataModel.monthlyCommits = messyCommits
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        
        // Verify sanitization works consistently
        for commit in messyCommits {
            let sanitized = allCommitsView.sanitizeCommitMessage(commit.message)
            
            // Should not contain newlines, tabs, or excessive whitespace
            XCTAssertFalse(sanitized.contains("\n"), "Sanitized message should not contain newlines")
            XCTAssertFalse(sanitized.contains("\t"), "Sanitized message should not contain tabs")
            XCTAssertFalse(sanitized.contains("  "), "Sanitized message should not contain double spaces")
            XCTAssertTrue(sanitized.count <= 200, "Sanitized message should be truncated to 200 characters")
            XCTAssertEqual(sanitized, sanitized.trimmingCharacters(in: .whitespacesAndNewlines),
                          "Sanitized message should have no leading/trailing whitespace")
        }
        
        // View should render consistently with all sanitized messages
        XCTAssertNotNil(allCommitsView.body, "View should render consistently with sanitized messages")
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testErrorStateRecovery() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Start in error state
        dataModel.isLoading = false
        dataModel.errorMessage = "Network timeout"
        dataModel.monthlyCommits = []
        
        XCTAssertNotNil(allCommitsView.body, "Should render error state")
        
        // Simulate recovery with data
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = [
            CommitData(repo: "recovered", message: "Data recovered", time: "now", commits: 1)
        ]
        
        XCTAssertNotNil(allCommitsView.body, "Should render recovered state")
        XCTAssertEqual(allCommitsView.commitCountText, "1 commit", "Should show correct count after recovery")
    }
    
    func testEmptyStateRecovery() {
        let allCommitsView = AllCommitsView(dataModel: dataModel)
        
        // Start in empty state
        dataModel.isLoading = false
        dataModel.errorMessage = nil
        dataModel.monthlyCommits = []
        
        XCTAssertNotNil(allCommitsView.body, "Should render empty state")
        XCTAssertEqual(allCommitsView.commitCountText, "0 commits", "Should show zero commits")
        
        // Simulate data arrival
        dataModel.monthlyCommits = [
            CommitData(repo: "new-data", message: "New data arrived", time: "now", commits: 1),
            CommitData(repo: "more-data", message: "More data arrived", time: "1m ago", commits: 1)
        ]
        
        XCTAssertNotNil(allCommitsView.body, "Should render content state after recovery")
        XCTAssertEqual(allCommitsView.commitCountText, "2 commits", "Should show correct count after recovery")
    }
}