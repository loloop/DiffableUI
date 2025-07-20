# Getting Started

Learn how to integrate DiffableUI into your project and create your first collection view.

## Overview

DiffableUI provides a declarative, SwiftUI-like API for building UIKit collection views. This guide will walk you through installation, basic setup, and creating your first collection view.

## Installation

### Swift Package Manager

Add DiffableUI to your project through Xcode:

1. In Xcode, select **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/loloop/DiffableUI.git`
3. Select the version you want to use
4. Add DiffableUI to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/loloop/DiffableUI.git", from: "0.0.1")
]
```

## Creating Your First Collection View

### Step 1: Create a View Controller

Create a new view controller that inherits from `DiffableViewController`:

```swift
import UIKit
import DiffableUI

class MyViewController: DiffableViewController {
    // Your view controller code
}
```

### Step 2: Define Your Sections

Override the `sections` property and use the `@CollectionViewBuilder` attribute:

```swift
class MyViewController: DiffableViewController {
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            Text("Hello, World!")
            Text("Welcome to DiffableUI")
        }
    }
}
```

### Step 3: Add Interactivity

Add buttons and handle user interactions:

```swift
class MyViewController: DiffableViewController {
    @State private var counter = 0
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            Text("Counter: \(counter)")
            
            Button("Increment") {
                counter += 1
                reload() // Refresh the collection view
            }
        }
    }
}
```

## Common Patterns

### Using Multiple Sections

You can combine different section types in a single collection view:

```swift
@CollectionViewBuilder
override var sections: [any CollectionSection] {
    ListSection(header: "List Items") {
        Text("Item 1")
        Text("Item 2")
    }
    
    GridSection(columns: 2, header: "Grid Items") {
        for i in 0..<6 {
            Text("Grid \(i)")
        }
    }
    
    CarouselSection {
        Text("Carousel Item 1")
        Text("Carousel Item 2")
        Text("Carousel Item 3")
    }
}
```

### Handling Data

Work with your data models by conforming them to appropriate protocols:

```swift
struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
}

class TodoViewController: DiffableViewController {
    @State private var todos = [
        TodoItem(title: "Learn DiffableUI", isCompleted: false),
        TodoItem(title: "Build an app", isCompleted: false)
    ]
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ForEach(todos) { todo in
                HStack {
                    Text(todo.title)
                    if todo.isCompleted {
                        Text("✓").foregroundColor(.systemGreen)
                    }
                }
                .onTap {
                    // Toggle completion
                    if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                        todos[index] = TodoItem(
                            title: todo.title,
                            isCompleted: !todo.isCompleted
                        )
                        reload()
                    }
                }
            }
        }
    }
}
```

### Loading States

Show loading indicators while fetching data:

```swift
class DataViewController: DiffableViewController {
    @State private var isLoading = true
    @State private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            if isLoading {
                ActivityIndicator()
                    .centerAligned()
            } else {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
    
    private func loadData() {
        // Simulate network request
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.items = ["Item 1", "Item 2", "Item 3"]
                self.isLoading = false
                self.reload()
            }
        }
    }
}
```

## Next Steps

- Explore the [example project](https://github.com/loloop/DiffableUI/tree/main/Examples/HackerNews) for a complete implementation
- Learn about <doc:CreatingCustomItems> to build your own reusable components
- Discover advanced layouts in <doc:CreatingCustomSections>
- Implement user interactions with <doc:HandlingUserInteraction>