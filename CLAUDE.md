# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DiffableUI is a Swift Package that provides a SwiftUI-like declarative API for building UIKit collection views using UICollectionViewCompositionalLayout and UICollectionViewDiffableDataSource. It targets iOS 14+ and is built with Swift 5.9.

## Key Architecture Concepts

### Core Protocols
- **CollectionItem**: Protocol for items that can be displayed in collection views. Items must be Hashable and provide a cell registration.
- **CollectionSection**: Protocol for sections containing collection items. Sections handle their own layout configuration.
- **CollectionView**: The main component that wraps UICollectionView with a declarative API and result builders.

### Result Builders
The library uses `@CollectionViewBuilder` to enable SwiftUI-like syntax for building collection view content declaratively.

### Extension Pattern
The codebase extensively uses protocol extensions to add functionality like `.onTap`, `.padding`, `.swipeActions` etc., mimicking SwiftUI's modifier pattern.

## Development Commands

```bash
# Build the library
swift build

# Open the example project
open Examples/HackerNews/HackerNews.xcodeproj

# Build via GitHub Actions (automatically triggered on push)
# See .github/workflows/build.yml
```

Note: Tests are currently commented out in Package.swift. When implementing tests, uncomment the test target and use `swift test`.

## Code Organization

- `Sources/DiffableUI/`: Main library code
  - `Items/`: Pre-built collection item types (Text, Button, ActivityIndicator, etc.)
  - `Sections/`: Section implementations (ListSection, GridSection, CarouselSection, etc.)
  - `UI/`: UI components and collection view implementation
  - `Protocols/`: Core protocol definitions
  - `Extensions/`: SwiftUI-style modifier extensions

- `Examples/HackerNews/`: Example app demonstrating library usage
  - Shows pagination, loading states, and real API integration
  - Good reference for implementing custom items and sections

## Important Implementation Notes

1. **Custom Items**: When creating custom collection items, ensure they:
   - Conform to `CollectionItem` protocol
   - Are `Hashable` (usually by including a unique identifier)
   - Provide proper cell registration via `cellRegistration` property

2. **Diffable Data Source**: The library handles diffing automatically. Items must be truly unique (proper Hashable implementation) to avoid animation issues.

3. **Layout**: Each section type provides its own compositional layout. Custom sections should implement the `layout(environment:)` method.

4. **SwiftUI-like Modifiers**: When adding new modifiers, follow the existing pattern of creating protocol extensions that return modified versions of items.

## Common Tasks

### Adding a New Item Type
1. Create a new struct conforming to `CollectionItem`
2. Implement required properties and cell registration
3. Add any custom modifiers as protocol extensions
4. See `Sources/DiffableUI/Items/Text.swift` for reference

### Adding a New Section Type
1. Create a new struct conforming to `CollectionSection`
2. Implement the layout configuration
3. Handle any special behaviors (like headers/footers)
4. See `Sources/DiffableUI/Sections/ListSection.swift` for reference

### Debugging Collection View Issues
- Check that items have unique hash values
- Verify cell registrations are correct
- Use `.allowsSelection` and `.deselectOnSelection` modifiers for selection behavior
- For performance issues, check if sections are properly implementing compositional layouts