# GitStreak Tests

This directory contains comprehensive tests for the GitStreak application, focusing on integration tests and functional tests that cover edge cases and real-world scenarios.

## Test Structure

### 1. GitStreakIntegrationTests.swift
Integration tests covering:
- **Week Boundary Calculations**: Sunday to Monday transitions, week start/end logic
- **Timezone Scenarios**: UTC commits in different local timezones, daylight saving transitions
- **Date Parsing**: GitHub API timestamp formats, invalid formats, edge cases
- **Empty Data Handling**: Empty commit arrays, parsing failures, mixed valid/invalid data
- **Calendar Edge Cases**: Leap years, month boundaries, year boundaries

### 2. GitHubServiceFunctionalTests.swift
Functional tests for GitHub API integration:
- **Token Validation**: Valid/invalid GitHub token formats (classic and fine-grained)
- **API Request Construction**: URL building, header setup
- **JSON Parsing**: User data, commit data, empty results, malformed JSON
- **Contribution Stats**: Calculation logic, empty data handling
- **Date Formatting**: Relative time formatting, invalid date handling
- **Error Handling**: GitHub API errors, network failures

### 3. KeychainHelperTests.swift
Security and persistence tests:
- **Basic Operations**: Save, read, delete keychain items
- **Token Management**: GitHub token storage and retrieval
- **Edge Cases**: Empty data, large data, unicode handling
- **Multiple Items**: Different keys, service isolation
- **Performance**: Bulk operations, concurrent access
- **Security**: Persistence across app restarts

### 4. GitStreakDataModelTests.swift
State management and data consistency tests:
- **Initialization**: Default values, weekly data, achievements setup
- **State Management**: Loading states, error handling, Combine publishers
- **Weekly Data Updates**: Commit aggregation, consistency checks
- **Level Calculations**: XP calculation, level titles, progress tracking
- **Achievement Logic**: Unlock conditions, state updates
- **Data Consistency**: Streak validation, totals verification
- **Performance**: Large datasets, calculation efficiency

### 5. ViewComponentTests.swift
UI component unit tests:
- **View Structure**: Component instantiation, proper composition
- **Data Binding**: Model-view synchronization, state updates
- **User Interactions**: Tab selection, button actions
- **Edge Cases**: Extreme values, long strings, empty data
- **Accessibility**: Screen reader support, navigation
- **Performance**: Rendering efficiency, memory usage

## Running Tests

### Prerequisites
1. Xcode 14.0+
2. iOS 17.5+ Simulator
3. Swift 5.5+

### Command Line
```bash
# Run all tests
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'

# Run specific test class
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' -only-testing:GitStreakTests/GitStreakIntegrationTests

# Run specific test method
xcodebuild test -project GitStreak.xcodeproj -scheme GitStreak -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' -only-testing:GitStreakTests/GitStreakIntegrationTests/testWeekBoundaryCalculation_SundayToMondayTransition
```

### Xcode
1. Open `GitStreak.xcodeproj`
2. Select the GitStreak scheme
3. Choose an iOS Simulator
4. Press `⌘+U` to run all tests
5. Use Test Navigator (`⌘+6`) to run individual tests

## Test Coverage Areas

### Date and Time Handling
- Week boundary transitions (Sunday ↔ Monday)
- Timezone conversions and DST transitions
- GitHub API timestamp parsing
- Leap year and month boundary handling
- Calendar edge cases across different locales

### GitHub API Integration
- Authentication token validation
- API request construction and headers
- JSON response parsing and error handling
- Rate limiting and network failure scenarios
- Empty and malformed data handling

### Data Persistence and Security
- Keychain operations (save, read, delete)
- Token security and isolation
- Concurrent access patterns
- Data migration and app restart scenarios

### Business Logic
- Streak calculations with edge cases
- Level progression and XP calculations
- Achievement unlock conditions
- Weekly activity aggregation
- Data consistency validation

### User Interface
- Component rendering and structure
- State binding and updates
- User interaction handling
- Accessibility compliance
- Performance under load

## Test Data and Mocking

### Mock Data Patterns
- Realistic commit data with various timestamps
- Edge case scenarios (empty arrays, invalid dates)
- Extreme values (very large numbers, long strings)
- Cross-timezone test scenarios

### Test Utilities
- Date creation helpers for specific scenarios
- Mock GitHub commit generation
- Keychain isolation between tests
- State reset and cleanup utilities

## Continuous Integration

These tests are designed to run in CI environments:
- No external dependencies required
- Isolated test execution
- Deterministic results across environments
- Comprehensive error reporting
- Performance benchmarking

## Performance Benchmarks

Key performance tests include:
- Date calculation efficiency
- Large dataset handling
- Keychain operation speed
- View rendering performance
- Memory usage patterns

## Adding New Tests

When adding new functionality:
1. Add integration tests for date/time handling
2. Include functional tests for API interactions
3. Test data persistence and security
4. Verify UI component behavior
5. Add performance benchmarks for critical paths

## Troubleshooting

### Common Issues
- **Keychain Access**: Tests may fail on simulators with restricted keychain access
- **Timezone Tests**: Ensure consistent system timezone during test runs
- **GitHub API**: Some tests require valid token format validation
- **SwiftUI Testing**: ViewInspector dependency for advanced UI testing

### Test Environment Setup
- Use consistent iOS Simulator versions
- Clear keychain between test runs
- Reset app state before each test
- Mock external dependencies appropriately