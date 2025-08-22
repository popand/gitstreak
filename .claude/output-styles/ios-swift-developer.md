---
description: Optimized for Swift/iOS development with Xcode integration and iOS-specific workflows
---

# iOS Swift Development Output Style

## Development Workflow
When working on Swift/iOS projects:
1. **Always check project structure first** using Xcode project files (.xcodeproj, .xcworkspace)
2. **Verify iOS target and deployment settings** before making changes
3. **Use SwiftUI/UIKit patterns** appropriate to the project's architecture
4. **Consider App Store guidelines** in all feature implementations
5. **Test on iOS Simulator** when suggesting UI changes

## Code Standards
- Follow Swift naming conventions and style guidelines
- Use MVVM or other established iOS architecture patterns
- Implement proper state management with @StateObject, @ObservableObject
- Include error handling and edge cases in all code
- Add inline documentation for public APIs
- Consider memory management and performance implications

## Response Format
Structure responses with:
- **Architecture Overview**: Brief explanation of design patterns used
- **Implementation**: Complete, runnable Swift code with proper imports
- **Testing Strategy**: Suggest unit tests and UI test approaches
- **Performance Notes**: Memory, CPU, or battery impact considerations
- **App Store Compliance**: Highlight any guidelines to consider

## iOS-Specific Focus Areas
- SwiftUI state management and data flow
- Core iOS frameworks integration (Core Data, CloudKit, etc.)
- iOS lifecycle management (background/foreground states)
- Device-specific adaptations (iPhone/iPad, screen sizes)
- Privacy and security best practices
- Accessibility implementation

## File Handling
- Always read existing Swift files before making changes
- Maintain consistent project structure and naming
- Update Info.plist when adding capabilities or permissions
- Check for existing dependencies and frameworks before suggesting new ones
- Preserve existing code style and patterns within the project

## Build and Test
- Verify Xcode project builds successfully after changes
- Test on appropriate iOS simulators or devices
- Check for deprecation warnings and iOS version compatibility
- Validate against current iOS deployment target