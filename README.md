# DiffableUI

![](https://github.com/loloop/DiffableUI/actions/workflows/build.yml/badge.svg) ![](https://img.shields.io/badge/maintained-Yes-green) ![](https://img.shields.io/badge/swift-5.9-green) ![](https://img.shields.io/badge/iOS-14.0-red)

DiffableUI is a set of wrappers and helpers built on top of UICollectionViewCompositionalLayout and UICollectionViewDiffableDataSource to help you write clean, reusable and SwiftUI-like code on the UIKit world.

## How to use

To use DiffableUI, you must create a `UIViewController` that inherits from `DiffableViewController`, overwrite the `sections` computed variable and call `reload()` whenever you want the view to recompute, as such: 

```swift
final class ExampleViewController: DiffableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    reload()
  }

  @CollectionViewBuilder
  override var sections: [any CollectionSection] {
    List {
      Label("Hello DiffableUI!")
    }
  }
}
```

## Customizing

The building blocks of DiffableUI are `CollectionItem` and `CollectionSection`. A `CollectionItem` represents any cell that you might want to display on your `UICollectionView`, while a `CollectionSection` holds your items and knows how to lay them out on the view.

Creating your own items is easy, you just have to provide an identifier, a way to hold your model, a reuse identifier and a way to configure your cell with your model:

```swift
public struct Empty: CollectionItem {
  public init() {}
  public var id: AnyHashable { item.id }
  public var item = EmptyHashable()
  public var reuseIdentifier: String { "empty" }
  public func configure(cell: UICollectionViewCell) {}

  public struct EmptyHashable: Hashable {
    let id = UUID()
  }
}
```

For a slightly more complex way of using DiffableUI, check our [Hacker News example app](/Examples/HackerNews/), where we fetch the latest news and display them with a custom `CollectionItem`.

## Extending

DiffableUI is built with SwiftUI-like extensibility in mind. Use the library's extensions to add functionality:

```swift
@CollectionViewBuilder
  override var sections: [any CollectionSection] {
    List {
      Label("Hello DiffableUI!")
      .onTap {
        print("Hello, console!")
      }
    }
  }
```

or create your own by extending `CollectionItem` or its concrete implementations themselves directly:

```swift
extension Label {
  func largeRedTitle() -> Self {
    self
      .fontStyle(.largeTitle)
      .textColor(.red)
  }
}
```

To create a new `CollectionSection`, you must provide an identifier, some way to hold `[any CollectionItem]` and provide a function that returns a `NSCollectionLayoutSection`. Check out [List](/Sources/DiffableUI/UI/Sections/List.swift) for more details.

## Installation

You can add DiffableUI to your project by using Xcode's "Add Package Dependencies" option in the File menu, or add it as a dependency on your Package.swift file as:

```swift
dependencies: [
    .package(url: "https://github.com/loloop/DiffableUI",from: Version(0, 0, 1)),
  ],
```

## Contributing and TODOs

To contribute, just open a pull request and let's take it from there :) Here's a couple of suggestions:

- [ ] DocC Documentation
- [ ] Swipe Actions
- [ ] State management
- [ ] Unit tests
- [ ] Support for platforms other than iOS/iPadOS

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
