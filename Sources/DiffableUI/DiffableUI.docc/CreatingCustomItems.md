# Creating Custom Items

Learn how to create reusable custom collection items for your specific needs.

## Overview

While DiffableUI provides many built-in items like `Text`, `Button`, and `ActivityIndicator`, you'll often need to create custom items for your specific UI requirements. This guide shows you how to create custom collection items that integrate seamlessly with DiffableUI.

## Understanding CollectionItem

Custom items must conform to the `CollectionItem` protocol:

```swift
public protocol CollectionItem: Equatable, Hashable, Identifiable {
    associatedtype CellType: UICollectionViewCell
    associatedtype ItemType: Hashable & Equatable
    
    var id: AnyHashable { get }
    var item: ItemType { get }
    var cellClass: CellType.Type { get }
    var reuseIdentifier: String { get }
    
    func configure(cell: CellType)
    func didSelect()
    func setBehaviors(cell: CellType)
    func willDisplay()
}
```

## Creating a Simple Custom Item

Let's create a custom profile item that displays a user's avatar and name:

### Step 1: Create the Cell

First, create a custom `UICollectionViewCell`:

```swift
class ProfileCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Configure label
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Configure stack view
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(nameLabel)
        
        // Add to cell
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(image: UIImage?, name: String) {
        imageView.image = image
        nameLabel.text = name
    }
}
```

### Step 2: Create the Item

Now create the item that uses this cell:

```swift
struct ProfileItem: CollectionItem {
    typealias CellType = ProfileCell
    typealias ItemType = Profile
    
    struct Profile: Hashable {
        let name: String
        let imageName: String
    }
    
    let id = UUID()
    let item: Profile
    let reuseIdentifier = "ProfileCell"
    
    // Optional: Add action handling
    var onTap: (() -> Void)?
    
    init(name: String, imageName: String, onTap: (() -> Void)? = nil) {
        self.item = Profile(name: name, imageName: imageName)
        self.onTap = onTap
    }
    
    func configure(cell: ProfileCell) {
        let image = UIImage(systemName: item.imageName)
        cell.configure(image: image, name: item.name)
    }
    
    func didSelect() {
        onTap?()
    }
}
```

### Step 3: Use Your Custom Item

Use your custom item in a collection view:

```swift
class ContactsViewController: DiffableViewController {
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ProfileItem(name: "John Doe", imageName: "person.fill") {
                print("John's profile tapped")
            }
            
            ProfileItem(name: "Jane Smith", imageName: "person.fill")
            
            ProfileItem(name: "Bob Johnson", imageName: "person.fill")
        }
    }
}
```

## Advanced Custom Items

### Adding Modifiers

You can add SwiftUI-style modifiers to your custom items by creating extensions:

```swift
extension ProfileItem {
    func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        // Store disabled state and apply in configure(cell:)
        return copy
    }
    
    func badgeCount(_ count: Int) -> Self {
        var copy = self
        // Store badge count and display in cell
        return copy
    }
}
```

### Handling State Changes

For items that need to update based on state changes:

```swift
struct ToggleItem: CollectionItem {
    typealias CellType = ToggleCell
    typealias ItemType = ToggleState
    
    struct ToggleState: Hashable {
        let title: String
        let isOn: Bool
    }
    
    let id: UUID
    let item: ToggleState
    let reuseIdentifier = "ToggleCell"
    var onToggle: ((Bool) -> Void)?
    
    init(title: String, isOn: Bool, onToggle: ((Bool) -> Void)? = nil) {
        self.id = UUID()
        self.item = ToggleState(title: title, isOn: isOn)
        self.onToggle = onToggle
    }
    
    func configure(cell: ToggleCell) {
        cell.configure(title: item.title, isOn: item.isOn)
    }
    
    func setBehaviors(cell: ToggleCell) {
        cell.onToggle = { [weak self] isOn in
            self?.onToggle?(isOn)
        }
    }
}
```

### Creating Composite Items

You can create items that contain other views:

```swift
struct CardItem: CollectionItem {
    typealias CellType = CardCell
    typealias ItemType = CardContent
    
    struct CardContent: Hashable {
        let title: String
        let subtitle: String
        let imageURL: URL?
    }
    
    let id = UUID()
    let item: CardContent
    let reuseIdentifier = "CardCell"
    
    func configure(cell: CardCell) {
        cell.configure(
            title: item.title,
            subtitle: item.subtitle,
            imageURL: item.imageURL
        )
    }
    
    func willDisplay() {
        // Start loading image when cell will be displayed
        ImageLoader.shared.preload(item.imageURL)
    }
}
```

## Best Practices

### 1. Keep Items Lightweight

Items should be value types (structs) that are cheap to create and copy:

```swift
// Good: Lightweight struct
struct LabelItem: CollectionItem {
    let id = UUID()
    let text: String
    // ...
}

// Avoid: Heavy reference types
class HeavyItem: CollectionItem { // Don't do this
    var largeData: Data
    // ...
}
```

### 2. Use Unique Identifiers

Always ensure your items have truly unique identifiers:

```swift
struct MessageItem: CollectionItem {
    let id: String // Use message ID from your backend
    let message: Message
    
    init(message: Message) {
        self.id = message.id // Unique ID from data model
        self.message = message
    }
}
```

### 3. Handle Cell Reuse Properly

Always fully configure cells in `configure(cell:)` to handle cell reuse:

```swift
func configure(cell: MyCell) {
    cell.titleLabel.text = item.title
    cell.subtitleLabel.text = item.subtitle
    
    // Reset optional states
    cell.imageView.image = nil
    cell.badgeView.isHidden = item.badgeCount == 0
}
```

### 4. Separate Behaviors from Configuration

Use `setBehaviors(cell:)` for one-time setup like gesture recognizers:

```swift
func setBehaviors(cell: MyCell) {
    let longPress = UILongPressGestureRecognizer(
        target: cell,
        action: #selector(cell.handleLongPress)
    )
    cell.addGestureRecognizer(longPress)
}
```

## Next Steps

- Learn about <doc:CreatingCustomSections> to create custom layouts
- Explore <doc:HandlingUserInteraction> for advanced interaction patterns
- See the example project for more complex custom items