# ``DiffableUI``

A SwiftUI-like declarative API for building UIKit collection views with compositional layouts and diffable data sources.

## Overview

DiffableUI brings the simplicity and expressiveness of SwiftUI's declarative syntax to UIKit's powerful collection view system. Built on top of `UICollectionViewCompositionalLayout` and `UICollectionViewDiffableDataSource`, it provides a modern way to create dynamic, performant collection views while maintaining full UIKit compatibility.

### Key Features

- **Declarative Syntax**: Build collection views using SwiftUI-like syntax with result builders
- **Type-Safe**: Leverage Swift's type system for compile-time safety
- **Performant**: Built on UIKit's diffable data source for automatic, efficient updates
- **Flexible Layouts**: Support for lists, grids, carousels, and custom compositional layouts
- **Extensible**: Easy to create custom items and sections
- **UIKit Integration**: Seamlessly integrates with existing UIKit code

## Topics

### Essentials

- <doc:GettingStarted>
- ``CollectionView``
- ``CollectionItem``
- ``CollectionSection``

### Building Collection Views

- ``CollectionViewBuilder``
- ``ListSection``
- ``GridSection``
- ``CarouselSection``
- ``HStackSection``
- ``PagingSection``

### Common Items

- ``Text``
- ``Button``
- ``ActivityIndicator``
- ``Separator``
- ``Space``
- ``PageControl``

### Advanced Items

- ``LazyItem``
- ``LoadingItem``
- ``InteractiveItem``
- ``SelectableItem``

### Customization

- <doc:CreatingCustomItems>
- <doc:CreatingCustomSections>
- <doc:HandlingUserInteraction>

### Examples

- <doc:BuildingANewsFeed>
- <doc:CreatingAPhotoGrid>
- <doc:ImplementingPagination>