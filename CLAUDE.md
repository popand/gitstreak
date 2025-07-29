# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
- **Build and Run**: Use Xcode (⌘+R) or open `GitStreak.xcodeproj` and select a simulator
- **Target**: iOS 17.5+ (configured in project.pbxproj)
- **Bundle ID**: com.gitstreak.app
- **Prerequisites**: Xcode 14.0+, iOS 14.0+ device/simulator, macOS Big Sur+

### Common Development Tasks
- **Open Project**: `open GitStreak.xcodeproj`
- **Simulator Selection**: Choose iOS Simulator from Xcode device dropdown
- **Build Configuration**: Debug/Release configurations available in project settings

## Code Architecture

### Project Structure
```
GitStreak/
├── GitStreakApp.swift          # App entry point with @main
├── ContentView.swift           # Main container with tab navigation, view routing, and SettingsView
├── Models/
│   └── GitStreakData.swift     # Data models, GitHubService, and ObservableObject classes
└── Views/
    ├── StreakCardView.swift    # Current streak display with gradient background and loading state
    ├── LevelProgressView.swift # Level and XP progress visualization
    ├── WeeklyActivityView.swift # Weekly commit activity chart
    ├── RecentActivityView.swift # Recent commits list
    ├── AchievementsView.swift  # Achievement badges display
    └── TabBarView.swift        # Custom tab bar with 4 tabs (Home, Awards, Stats, Social)
```

### Architecture Pattern
- **MVVM**: Uses SwiftUI's ObservableObject pattern with `GitStreakDataModel`
- **State Management**: Single `@StateObject` dataModel shared across views
- **Navigation**: Custom tab-based navigation with `selectedTab` binding
- **Data Flow**: All data flows through `GitStreakDataModel` using `@Published` properties

### Key Components
- **GitStreakDataModel**: Central data store with GitHub integration and mock data fallback
- **GitHubService**: Handles GitHub API authentication and data fetching (consolidated in GitStreakData.swift)
- **ContentView**: Main coordinator with tab switching, HomeView, and SettingsView
- **HomeView**: Primary view with dynamic greeting and GitHub integration status
- **SettingsView**: GitHub authentication UI with token input and account management
- **Tab Navigation**: Custom TabBarView with 4 tabs, Home tab fully functional with GitHub integration

### Data Models
- **CommitData**: Identifiable struct for recent commit information
- **WeeklyData**: Represents daily commit activity for the week
- **Achievement**: Unlockable achievement badges with icons and descriptions

### UI Patterns
- **SwiftUI Native**: Uses system colors, materials, and SF Symbols
- **Responsive Design**: Adapts to different iOS screen sizes
- **Design System**: Consistent spacing (24px horizontal padding), corner radius (16px), and gradients
- **Mock Data**: All data is currently hardcoded in GitStreakDataModel for demonstration

### Current Status
- **GitHub Integration**: Fully functional with Personal Access Token authentication
- **Home Tab**: Dynamic content with real GitHub data when authenticated, falls back to mock data
- **Settings**: Complete GitHub authentication flow accessible via gear icon
- **Other Tabs**: Awards, Stats, and Social tabs show "Coming Soon" placeholders
- **No External Dependencies**: Uses only SwiftUI, Foundation, and native GitHub API