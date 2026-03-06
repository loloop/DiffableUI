# Creating Custom Sections

Learn how to create custom section layouts for unique collection view designs.

## Overview

DiffableUI provides several built-in section types like `ListSection`, `GridSection`, and `CarouselSection`. However, you can create custom sections to achieve unique layouts using UIKit's compositional layout system.

## Understanding CollectionSection

Custom sections must conform to the `CollectionSection` protocol:

```swift
public protocol CollectionSection: Equatable {
    var id: AnyHashable { get }
    var items: [any CollectionItem] { get }
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}
```

## Creating a Simple Custom Section

Let's create a staggered grid section where items have varying heights:

```swift
struct StaggeredGridSection: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    let columns: Int
    
    init(columns: Int = 2, @CollectionItemBuilder content: () -> [any CollectionItem]) {
        self.columns = columns
        self.items = content()
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Create a group with multiple columns
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .estimated(100) // Dynamic height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: columns
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        return section
    }
}
```

## Advanced Layout Examples

### Horizontal Scrolling Section

Create a section that scrolls horizontally with paging:

```swift
struct HorizontalPagingSection: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    let itemWidth: CGFloat
    
    init(itemWidth: CGFloat = 0.8, @CollectionItemBuilder content: () -> [any CollectionItem]) {
        self.itemWidth = itemWidth
        self.items = content()
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemWidth),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemWidth),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 0
        
        // Add page control as supplementary view
        section.visibleItemsInvalidationHandler = { items, contentOffset, environment in
            let currentPage = Int(round(contentOffset.x / environment.container.contentSize.width * CGFloat(items.count)))
            // Update page control
        }
        
        return section
    }
}
```

### Waterfall Layout Section

Create a Pinterest-style waterfall layout:

```swift
struct WaterfallSection: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    let columns: Int
    
    init(columns: Int = 2, @CollectionItemBuilder content: () -> [any CollectionItem]) {
        self.columns = columns
        self.items = content()
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        // Create custom layout with provider
        let section = NSCollectionLayoutSection(group: createWaterfallGroup())
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createWaterfallGroup() -> NSCollectionLayoutGroup {
        // Implementation of waterfall algorithm
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        
        return NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: columns
        )
    }
}
```

## Adding Headers and Footers

Sections can include supplementary views like headers and footers:

```swift
struct SectionWithHeader: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    let title: String
    
    init(title: String, @CollectionItemBuilder content: () -> [any CollectionItem]) {
        self.title = title
        self.items = content()
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Create basic list layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // Add header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true // Sticky header
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
```

## Adaptive Layouts

Create sections that adapt to different size classes:

```swift
struct AdaptiveGridSection: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    
    init(@CollectionItemBuilder content: () -> [any CollectionItem]) {
        self.items = content()
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Determine columns based on container width
        let containerWidth = environment.container.contentSize.width
        let columns: Int
        
        switch containerWidth {
        case 0..<400:
            columns = 2
        case 400..<600:
            columns = 3
        case 600..<800:
            columns = 4
        default:
            columns = 5
        }
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .aspectRatio(1.0) // Square items
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / CGFloat(columns))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: columns
        )
        
        return NSCollectionLayoutSection(group: group)
    }
}
```

## Animating Section Changes

Add custom animations to your sections:

```swift
struct AnimatedSection: CollectionSection {
    let id = UUID()
    let items: [any CollectionItem]
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = createBasicLayout()
        
        // Add animation behavior
        section.visibleItemsInvalidationHandler = { items, offset, environment in
            items.forEach { item in
                let distanceFromCenter = abs(item.center.x - (offset.x + environment.container.contentSize.width / 2))
                let scale = max(0.8, 1 - (distanceFromCenter / environment.container.contentSize.width))
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        return section
    }
    
    private func createBasicLayout() -> NSCollectionLayoutSection {
        // Your layout implementation
    }
}
```

## Best Practices

### 1. Use Environment Information

Always consider the layout environment when creating sections:

```swift
func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let isCompact = environment.traitCollection.horizontalSizeClass == .compact
    let columns = isCompact ? 2 : 4
    // Adjust layout based on trait collection
}
```

### 2. Performance Considerations

For large datasets, use estimated dimensions:

```swift
// Good: Allows dynamic sizing
let itemSize = NSCollectionLayoutSize(
    widthDimension: .fractionalWidth(1.0),
    heightDimension: .estimated(100)
)

// Avoid for dynamic content
let itemSize = NSCollectionLayoutSize(
    widthDimension: .fractionalWidth(1.0),
    heightDimension: .absolute(100) // Fixed height
)
```

### 3. Reusable Section Components

Create reusable section configurations:

```swift
extension NSCollectionLayoutSection {
    static func list(spacing: CGFloat = 0) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        
        return section
    }
}
```

## Next Steps

- Explore <doc:HandlingUserInteraction> for adding gestures to sections
- Learn about performance optimization in <doc:BuildingANewsFeed>
- See more examples in the [HackerNews sample app](https://github.com/loloop/DiffableUI/tree/main/Examples/HackerNews)