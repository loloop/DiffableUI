# Handling User Interaction

Learn how to handle taps, swipes, and other user interactions in your collection views.

## Overview

DiffableUI provides multiple ways to handle user interactions, from simple taps to complex gestures. This guide covers the various interaction patterns and best practices for creating responsive, interactive collection views.

## Basic Tap Handling

### Using onTap Modifier

The simplest way to handle taps is using the `.onTap` modifier:

```swift
@CollectionViewBuilder
override var sections: [any CollectionSection] {
    ListSection {
        Text("Tap me")
            .onTap {
                print("Text was tapped!")
            }
        
        Button("Button") {
            print("Button pressed!")
        }
    }
}
```

### Implementing didSelect

For custom items, implement the `didSelect()` method:

```swift
struct CustomItem: CollectionItem {
    let id = UUID()
    let title: String
    var onSelect: (() -> Void)?
    
    func didSelect() {
        onSelect?()
        // Perform selection action
    }
}
```

## Selection States

### Single Selection

Track and display selection state:

```swift
class SelectionViewController: DiffableViewController {
    @State private var selectedID: String?
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ForEach(items) { item in
                SelectableItem(
                    content: Text(item.title),
                    isSelected: selectedID == item.id
                )
                .onTap {
                    selectedID = item.id
                    reload()
                }
            }
        }
    }
}
```

### Multiple Selection

Handle multiple selection with a Set:

```swift
class MultiSelectViewController: DiffableViewController {
    @State private var selectedIDs = Set<String>()
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ForEach(items) { item in
                HStack {
                    Image(systemName: selectedIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.systemBlue)
                    Text(item.title)
                }
                .onTap {
                    if selectedIDs.contains(item.id) {
                        selectedIDs.remove(item.id)
                    } else {
                        selectedIDs.insert(item.id)
                    }
                    reload()
                }
            }
        }
    }
}
```

## Swipe Actions

### Basic Swipe to Delete

Implement swipe actions on items:

```swift
@CollectionViewBuilder
override var sections: [any CollectionSection] {
    ListSection {
        ForEach(todos) { todo in
            Text(todo.title)
                .swipeActions {
                    SwipeAction(
                        title: "Delete",
                        backgroundColor: .systemRed
                    ) {
                        deleteTodo(todo)
                    }
                }
        }
    }
}
```

### Multiple Swipe Actions

Add multiple actions with different styles:

```swift
Text(email.subject)
    .swipeActions {
        SwipeAction(
            title: "Archive",
            backgroundColor: .systemBlue,
            image: UIImage(systemName: "archivebox")
        ) {
            archiveEmail(email)
        }
        
        SwipeAction(
            title: "Flag",
            backgroundColor: .systemOrange,
            image: UIImage(systemName: "flag")
        ) {
            flagEmail(email)
        }
        
        SwipeAction(
            title: "Delete",
            backgroundColor: .systemRed,
            image: UIImage(systemName: "trash"),
            style: .destructive
        ) {
            deleteEmail(email)
        }
    }
```

## Long Press Gestures

### Adding Long Press

Add long press recognition to items:

```swift
struct LongPressItem: CollectionItem {
    // ... item implementation
    
    func setBehaviors(cell: CellType) {
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Show context menu or perform action
            showContextMenu()
        }
    }
}
```

### Context Menus

Provide context menus for additional actions:

```swift
Text("Long press for options")
    .contextMenu {
        UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
            copyText()
        }
        
        UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            shareText()
        }
        
        UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            deleteItem()
        }
    }
```

## Drag and Drop

### Enabling Drag

Make items draggable:

```swift
struct DraggableItem: CollectionItem {
    // ... item implementation
    
    func setBehaviors(cell: CellType) {
        cell.addInteraction(
            UIDragInteraction(delegate: self)
        )
    }
}

extension DraggableItem: UIDragInteractionDelegate {
    func dragInteraction(
        _ interaction: UIDragInteraction,
        itemsForBeginning session: UIDragSession
    ) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: item.title as NSString)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}
```

### Handling Drop

Accept dropped items:

```swift
class DragDropViewController: DiffableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.addInteraction(
            UIDropInteraction(delegate: self)
        )
    }
}

extension DragDropViewController: UIDropInteractionDelegate {
    func dropInteraction(
        _ interaction: UIDropInteraction,
        performDrop session: UIDropSession
    ) {
        // Handle the drop
        session.loadObjects(ofClass: NSString.self) { items in
            // Process dropped items
        }
    }
}
```

## Interactive Animations

### Tap Feedback

Provide visual feedback for taps:

```swift
struct AnimatedTapItem: CollectionItem {
    func configure(cell: CellType) {
        // Configure cell
    }
    
    func setBehaviors(cell: CellType) {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        cell.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view else { return }
        
        UIView.animate(
            withDuration: 0.1,
            animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
                self.didSelect()
            }
        )
    }
}
```

### Interactive Transitions

Create smooth interactive transitions:

```swift
class InteractiveViewController: DiffableViewController {
    @State private var expandedItemID: String?
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ForEach(items) { item in
                if expandedItemID == item.id {
                    ExpandedItemView(item: item)
                        .onTap {
                            withAnimation {
                                expandedItemID = nil
                                reload()
                            }
                        }
                } else {
                    CollapsedItemView(item: item)
                        .onTap {
                            withAnimation {
                                expandedItemID = item.id
                                reload()
                            }
                        }
                }
            }
        }
    }
}
```

## Best Practices

### 1. Provide Feedback

Always provide visual or haptic feedback for interactions:

```swift
func didSelect() {
    // Haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
    
    // Visual feedback handled by the cell
    onSelect?()
}
```

### 2. Handle State Consistently

Ensure your interaction state is consistent:

```swift
class StateViewController: DiffableViewController {
    @State private var processingItemIDs = Set<String>()
    
    func processItem(_ item: Item) {
        guard !processingItemIDs.contains(item.id) else { return }
        
        processingItemIDs.insert(item.id)
        reload()
        
        Task {
            await performProcessing(item)
            processingItemIDs.remove(item.id)
            reload()
        }
    }
}
```

### 3. Respect Platform Conventions

Follow iOS interaction patterns:

```swift
// Use standard iOS gestures
Text("Swipe left for actions")
    .swipeActions(edge: .trailing) { /* ... */ }

// Use familiar icons
Button(action: { /* ... */ }) {
    Image(systemName: "ellipsis")
}
```

### 4. Accessibility

Ensure interactions are accessible:

```swift
func configure(cell: CellType) {
    cell.isAccessibilityElement = true
    cell.accessibilityLabel = item.title
    cell.accessibilityHint = "Double tap to view details"
    cell.accessibilityTraits = .button
}
```

## Next Steps

- Explore animation techniques in <doc:BuildingANewsFeed>
- Learn about performance optimization for interactive lists
- See the HackerNews example for complex interaction patterns