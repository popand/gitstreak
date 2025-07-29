# Xcode Project Setup for GitStreak Tests

This document provides instructions for setting up the test target in Xcode for the GitStreak project.

## Creating the Test Target

### Step 1: Add Test Target to Xcode Project

1. Open `GitStreak.xcodeproj` in Xcode
2. Select the project in the navigator (top-level GitStreak item)
3. Click the "+" button at the bottom of the targets list
4. Choose "iOS Unit Testing Bundle"
5. Configure the target:
   - **Product Name**: `GitStreakTests`
   - **Team**: (Select your development team)
   - **Bundle Identifier**: `com.gitstreak.app.tests`
   - **Language**: Swift
   - **Target to be Tested**: GitStreak

### Step 2: Configure Test Target Settings

#### Build Settings
- **iOS Deployment Target**: 17.5
- **Swift Language Version**: Swift 5
- **Code Signing**: (Use your development team)

#### Info.plist
The test target should use the `Info.plist` file created in the GitStreakTests directory.

### Step 3: Add Test Files to Target

Add all test files to the GitStreakTests target:
- `GitStreakIntegrationTests.swift`
- `GitHubServiceFunctionalTests.swift`
- `KeychainHelperTests.swift`
- `GitStreakDataModelTests.swift`
- `ViewComponentTests.swift`

### Step 4: Configure Test Host

In the test target's build settings:
- **Test Host**: `$(BUILT_PRODUCTS_DIR)/GitStreak.app/GitStreak`
- **Bundle Loader**: `$(TEST_HOST)`

## Project Structure After Setup

```
GitStreak.xcodeproj
├── GitStreak/                          # Main app target
│   ├── GitStreakApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   │   └── GitStreakData.swift
│   └── Views/
│       ├── StreakCardView.swift
│       ├── LevelProgressView.swift
│       ├── WeeklyActivityView.swift
│       ├── RecentActivityView.swift
│       ├── AchievementsView.swift
│       └── TabBarView.swift
└── GitStreakTests/                     # Test target
    ├── Info.plist
    ├── GitStreakIntegrationTests.swift
    ├── GitHubServiceFunctionalTests.swift
    ├── KeychainHelperTests.swift
    ├── GitStreakDataModelTests.swift
    ├── ViewComponentTests.swift
    └── README.md
```

## Build Phases Configuration

### Test Target Build Phases

1. **Target Dependencies**: GitStreak
2. **Compile Sources**: All test Swift files
3. **Link Binary With Libraries**: 
   - XCTest.framework
   - Foundation.framework
   - UIKit.framework
   - SwiftUI.framework
   - Combine.framework
   - Security.framework

## Scheme Configuration

### GitStreak Scheme Test Action

1. Open the scheme editor (Product → Scheme → Edit Scheme...)
2. Select "Test" from the left sidebar
3. Ensure GitStreakTests is listed under "Test"
4. Configure:
   - **Build Configuration**: Debug
   - **Debugger**: Xcode Debugger
   - **Language**: System Language
   - **Region**: System Region

### Additional Test Settings

- **Code Coverage**: Enable "Gather coverage for all tests"
- **Test Plans**: Consider creating test plans for different test suites
- **Arguments**: Add any necessary launch arguments or environment variables

## Dependencies and Frameworks

### Required Frameworks
```swift
import XCTest
import Foundation
import SwiftUI
import Combine
import Security
@testable import GitStreak
```

### Optional Testing Frameworks

For enhanced SwiftUI testing, consider adding:
- **ViewInspector**: For SwiftUI view testing
- **SnapshotTesting**: For UI snapshot tests

Add via Swift Package Manager:
1. File → Add Package Dependencies...
2. Add ViewInspector: `https://github.com/nalexn/ViewInspector`

## Test Configuration

### Launch Arguments
Add to test scheme if needed:
- `-uitesting` for UI testing mode
- `-reset-keychain` to clear keychain before tests

### Environment Variables
- `IS_TESTING`: Set to "1" for test environment
- `MOCK_GITHUB_API`: Set to "1" to use mock API responses

## Running Tests

### From Xcode
- **All Tests**: `⌘+U`
- **Current Test**: Click the diamond icon next to test method
- **Test Class**: Click the diamond icon next to test class
- **Test Navigator**: `⌘+6` to see all tests

### From Command Line
```bash
# Basic test run
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'

# With code coverage
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' -enableCodeCoverage YES

# Specific test class
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' -only-testing:GitStreakTests/GitStreakIntegrationTests
```

## Code Signing for Tests

Tests typically don't require special code signing, but ensure:
- Development team is selected
- Provisioning profile allows testing
- Keychain tests may require additional entitlements

## Troubleshooting Setup Issues

### Common Problems

1. **"No such module 'GitStreak'"**
   - Ensure test target depends on main target
   - Check that `@testable import GitStreak` is correct

2. **Keychain Tests Failing**
   - Simulator keychain permissions
   - Test cleanup between runs

3. **SwiftUI Tests Not Working**
   - Add ViewInspector dependency
   - Check iOS deployment target compatibility

4. **Build Errors**
   - Verify all test files are added to test target
   - Check Swift language version consistency

### Performance Optimization

For faster test execution:
- Enable parallel testing in scheme settings
- Use test plans to group related tests
- Consider running unit tests separately from integration tests

## CI/CD Integration

For automated testing:
- Use consistent simulator versions
- Set up proper code signing for CI
- Export test results in JUnit format
- Generate code coverage reports

Example CI command:
```bash
xcodebuild test \
  -project GitStreak.xcodeproj \
  -scheme GitStreak \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -resultBundlePath TestResults \
  -enableCodeCoverage YES
```