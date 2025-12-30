# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

HashList is a native macOS SwiftUI application. This is a minimal project structure with the standard SwiftUI App lifecycle.

## Build and Run Commands

### Building the Project
```bash
# Build for Debug configuration
xcodebuild -project HashList.xcodeproj -scheme HashList -configuration Debug build

# Build for Release configuration
xcodebuild -project HashList.xcodeproj -scheme HashList -configuration Release build

# Clean build folder
xcodebuild -project HashList.xcodeproj -scheme HashList clean
```

### Running the Application
```bash
# Build and run (opens the app)
xcodebuild -project HashList.xcodeproj -scheme HashList -configuration Debug build && open build/Debug/HashList.app

# Or simply open the project in Xcode and run
open HashList.xcodeproj
```

### Testing
Currently, there are no test targets configured in this project. To add tests, create a new test target in Xcode.

Once tests are added, run them with:
```bash
# Run all tests
xcodebuild -project HashList.xcodeproj -scheme HashList test

# Run specific test
xcodebuild -project HashList.xcodeproj -scheme HashList -only-testing:HashListTests/TestClassName/testMethodName test
```

## Architecture

### Application Structure
- **HashListApp.swift**: Main entry point using `@main` attribute with SwiftUI App protocol
- **ContentView.swift**: Root view with SwiftUI previews enabled

### Platform & SDK
- **Target Platform**: macOS 26.1
- **Swift Version**: 5.0
- **Framework**: SwiftUI
- **Bundle Identifier**: sarkar.shubhdeep.HashList

### Project Organization
The project follows standard Xcode project structure:
- Source files are located in `HashList/` directory
- Assets are managed through `Assets.xcassets` catalog
- Project settings are in `HashList.xcodeproj/`

## Development Guidelines

### Swift & SwiftUI Conventions
- Use SwiftUI declarative syntax for all UI components
- Leverage `#Preview` macros for live previews during development
- Follow Swift naming conventions (camelCase for properties/methods, PascalCase for types)

### Building New Features
When adding new functionality:
1. Create separate Swift files for new views, models, or view models
2. Keep views focused and composable
3. Use SwiftUI property wrappers appropriately (@State, @Binding, @ObservedObject, etc.)
4. Place new assets in `Assets.xcassets`

### Xcode Schemes
The project has one scheme: **HashList**
- Default build configuration is **Release**
- Debug and Release configurations are both available
