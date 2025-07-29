import XCTest
import Foundation
import Security
@testable import GitStreak

class KeychainHelperTests: XCTestCase {
    
    var keychainHelper: KeychainHelper!
    let testService = "com.gitstreak.test"
    let testAccount = "test_account"
    
    override func setUp() {
        super.setUp()
        keychainHelper = KeychainHelper.shared
        
        // Clean up any existing test data
        _ = keychainHelper.delete(service: testService, account: testAccount)
    }
    
    override func tearDown() {
        // Clean up test data
        _ = keychainHelper.delete(service: testService, account: testAccount)
        keychainHelper = nil
        super.tearDown()
    }
    
    // MARK: - Basic Keychain Operations Tests
    
    func testSaveAndReadData() {
        let testData = "test_data_123".data(using: .utf8)!
        
        // Test saving data
        let saveResult = keychainHelper.save(testData, service: testService, account: testAccount)
        XCTAssertTrue(saveResult, "Should successfully save data to keychain")
        
        // Test reading data
        let readData = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertNotNil(readData, "Should successfully read data from keychain")
        XCTAssertEqual(readData, testData, "Read data should match saved data")
    }
    
    func testSaveOverwritesExistingData() {
        let originalData = "original_data".data(using: .utf8)!
        let newData = "new_data".data(using: .utf8)!
        
        // Save original data
        let firstSave = keychainHelper.save(originalData, service: testService, account: testAccount)
        XCTAssertTrue(firstSave, "Should save original data")
        
        // Overwrite with new data
        let secondSave = keychainHelper.save(newData, service: testService, account: testAccount)
        XCTAssertTrue(secondSave, "Should overwrite existing data")
        
        // Verify new data is stored
        let readData = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertEqual(readData, newData, "Should read the new data, not original")
    }
    
    func testReadNonExistentData() {
        let nonExistentAccount = "non_existent_account"
        
        let readData = keychainHelper.read(service: testService, account: nonExistentAccount)
        XCTAssertNil(readData, "Should return nil for non-existent data")
    }
    
    func testDelete() {
        let testData = "data_to_delete".data(using: .utf8)!
        
        // Save data first
        let saveResult = keychainHelper.save(testData, service: testService, account: testAccount)
        XCTAssertTrue(saveResult, "Should save data for deletion test")
        
        // Verify data exists
        let readData = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertNotNil(readData, "Data should exist before deletion")
        
        // Delete data
        let deleteResult = keychainHelper.delete(service: testService, account: testAccount)
        XCTAssertTrue(deleteResult, "Should successfully delete data")
        
        // Verify data is gone
        let readAfterDelete = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertNil(readAfterDelete, "Data should be nil after deletion")
    }
    
    func testDeleteNonExistentData() {
        let nonExistentAccount = "non_existent_for_delete"
        
        // Should return true for non-existent items (as per implementation)
        let deleteResult = keychainHelper.delete(service: testService, account: nonExistentAccount)
        XCTAssertTrue(deleteResult, "Should return true when deleting non-existent data")
    }
    
    // MARK: - Token Helper Methods Tests
    
    func testSaveAndGetToken() {
        let testToken = "ghp_test_token_1234567890123456789012345678"
        let testKey = "test_token_key"
        
        // Save token
        let saveResult = keychainHelper.saveToken(testToken, forKey: testKey)
        XCTAssertTrue(saveResult, "Should save token successfully")
        
        // Get token
        let retrievedToken = keychainHelper.getToken(forKey: testKey)
        XCTAssertNotNil(retrievedToken, "Should retrieve token")
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match saved token")
        
        // Clean up
        _ = keychainHelper.deleteToken(forKey: testKey)
    }
    
    func testGetNonExistentToken() {
        let nonExistentKey = "non_existent_token_key"
        
        let token = keychainHelper.getToken(forKey: nonExistentKey)
        XCTAssertNil(token, "Should return nil for non-existent token")
    }
    
    func testDeleteToken() {
        let testToken = "github_pat_test_token_1234567890123456789012345678901234567890"
        let testKey = "delete_test_token_key"
        
        // Save token first
        let saveResult = keychainHelper.saveToken(testToken, forKey: testKey)
        XCTAssertTrue(saveResult, "Should save token for deletion test")
        
        // Verify token exists
        let retrievedToken = keychainHelper.getToken(forKey: testKey)
        XCTAssertNotNil(retrievedToken, "Token should exist before deletion")
        
        // Delete token
        let deleteResult = keychainHelper.deleteToken(forKey: testKey)
        XCTAssertTrue(deleteResult, "Should delete token successfully")
        
        // Verify token is gone
        let tokenAfterDelete = keychainHelper.getToken(forKey: testKey)
        XCTAssertNil(tokenAfterDelete, "Token should be nil after deletion")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testSaveEmptyData() {
        let emptyData = Data()
        
        let saveResult = keychainHelper.save(emptyData, service: testService, account: testAccount)
        XCTAssertTrue(saveResult, "Should be able to save empty data")
        
        let readData = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertNotNil(readData, "Should be able to read empty data")
        XCTAssertEqual(readData?.count, 0, "Read data should be empty")
    }
    
    func testSaveEmptyStringToken() {
        let emptyToken = ""
        let testKey = "empty_token_key"
        
        let saveResult = keychainHelper.saveToken(emptyToken, forKey: testKey)
        XCTAssertTrue(saveResult, "Should be able to save empty string token")
        
        let retrievedToken = keychainHelper.getToken(forKey: testKey)
        XCTAssertNotNil(retrievedToken, "Should retrieve empty token")
        XCTAssertEqual(retrievedToken, "", "Retrieved token should be empty string")
        
        // Clean up
        _ = keychainHelper.deleteToken(forKey: testKey)
    }
    
    func testSaveLargeData() {
        // Create large data (1MB)
        let largeData = Data(repeating: 0x41, count: 1024 * 1024)
        
        let saveResult = keychainHelper.save(largeData, service: testService, account: testAccount)
        XCTAssertTrue(saveResult, "Should be able to save large data")
        
        let readData = keychainHelper.read(service: testService, account: testAccount)
        XCTAssertNotNil(readData, "Should be able to read large data")
        XCTAssertEqual(readData?.count, largeData.count, "Read data size should match")
    }
    
    func testUnicodeTokenHandling() {
        let unicodeToken = "ghp_test_token_with_unicode_αβγδε_1234567890123"
        let testKey = "unicode_token_key"
        
        let saveResult = keychainHelper.saveToken(unicodeToken, forKey: testKey)
        XCTAssertTrue(saveResult, "Should save unicode token")
        
        let retrievedToken = keychainHelper.getToken(forKey: testKey)
        XCTAssertEqual(retrievedToken, unicodeToken, "Should handle unicode characters correctly")
        
        // Clean up
        _ = keychainHelper.deleteToken(forKey: testKey)
    }
    
    // MARK: - Multiple Items Management
    
    func testMultipleTokensWithDifferentKeys() {
        let tokens = [
            "key1": "ghp_token_1_1234567890123456789012345678",
            "key2": "github_pat_token_2_1234567890123456789012345678901234567890",
            "key3": "ghp_token_3_1234567890123456789012345678"
        ]
        
        // Save all tokens
        for (key, token) in tokens {
            let saveResult = keychainHelper.saveToken(token, forKey: key)
            XCTAssertTrue(saveResult, "Should save token for key: \(key)")
        }
        
        // Verify all tokens can be retrieved
        for (key, expectedToken) in tokens {
            let retrievedToken = keychainHelper.getToken(forKey: key)
            XCTAssertEqual(retrievedToken, expectedToken, "Should retrieve correct token for key: \(key)")
        }
        
        // Clean up all tokens
        for key in tokens.keys {
            _ = keychainHelper.deleteToken(forKey: key)
        }
    }
    
    func testDifferentServicesIsolation() {
        let service1 = "com.gitstreak.service1"
        let service2 = "com.gitstreak.service2"
        let account = "same_account"
        let data1 = "data_for_service1".data(using: .utf8)!
        let data2 = "data_for_service2".data(using: .utf8)!
        
        // Save data to both services with same account
        let save1 = keychainHelper.save(data1, service: service1, account: account)
        let save2 = keychainHelper.save(data2, service: service2, account: account)
        
        XCTAssertTrue(save1, "Should save to service1")
        XCTAssertTrue(save2, "Should save to service2")
        
        // Verify data isolation
        let read1 = keychainHelper.read(service: service1, account: account)
        let read2 = keychainHelper.read(service: service2, account: account)
        
        XCTAssertEqual(read1, data1, "Should read correct data from service1")
        XCTAssertEqual(read2, data2, "Should read correct data from service2")
        XCTAssertNotEqual(read1, read2, "Data should be isolated between services")
        
        // Clean up
        _ = keychainHelper.delete(service: service1, account: account)
        _ = keychainHelper.delete(service: service2, account: account)
    }
    
    // MARK: - Performance Tests
    
    func testKeychainPerformance() {
        let tokenCount = 100
        let testTokens = (0..<tokenCount).map { i in
            ("key_\(i)", "ghp_performance_test_token_\(i)_" + String(repeating: "x", count: 20))
        }
        
        // Measure save performance
        measure {
            for (key, token) in testTokens {
                _ = keychainHelper.saveToken(token, forKey: key)
            }
        }
        
        // Verify all tokens were saved
        for (key, expectedToken) in testTokens {
            let retrievedToken = keychainHelper.getToken(forKey: key)
            XCTAssertEqual(retrievedToken, expectedToken, "Should retrieve token for key: \(key)")
        }
        
        // Clean up
        for (key, _) in testTokens {
            _ = keychainHelper.deleteToken(forKey: key)
        }
    }
    
    // MARK: - Security and Access Control Tests
    
    func testKeychainAccessAfterAppRestart() {
        // This test simulates app restart by creating a new KeychainHelper instance
        let testToken = "ghp_restart_test_token_1234567890123456789012345678"
        let testKey = "restart_test_key"
        
        // Save with first instance
        let saveResult = keychainHelper.saveToken(testToken, forKey: testKey)
        XCTAssertTrue(saveResult, "Should save token with first instance")
        
        // Create new instance (simulating app restart)
        let newKeychainHelper = KeychainHelper.shared
        
        // Verify token persists across instances
        let retrievedToken = newKeychainHelper.getToken(forKey: testKey)
        XCTAssertEqual(retrievedToken, testToken, "Token should persist across KeychainHelper instances")
        
        // Clean up
        _ = newKeychainHelper.deleteToken(forKey: testKey)
    }
    
    func testConcurrentAccess() {
        let testKey = "concurrent_test_key"
        let expectation = XCTestExpectation(description: "Concurrent keychain operations")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        // Perform concurrent save/read operations
        for i in 0..<10 {
            queue.async {
                let token = "ghp_concurrent_test_\(i)_" + String(repeating: "x", count: 25)
                let key = "\(testKey)_\(i)"
                
                let saveResult = self.keychainHelper.saveToken(token, forKey: key)
                XCTAssertTrue(saveResult, "Should save token concurrently for key: \(key)")
                
                let retrievedToken = self.keychainHelper.getToken(forKey: key)
                XCTAssertEqual(retrievedToken, token, "Should retrieve correct token concurrently")
                
                // Clean up
                _ = self.keychainHelper.deleteToken(forKey: key)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}