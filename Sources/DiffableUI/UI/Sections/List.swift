//
//  List.swift
//
//
//  Created by Mauricio Cardozo on 10/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// A section that displays items in a vertical list layout.
///
/// `List` arranges items vertically, one per row, similar to a UITableView.
/// It supports customizable item heights and spacing.
///
/// ## Example
///
/// ```swift
/// List {
///     Label("Item 1")
///     Label("Item 2")
///     Label("Item 3")
/// }
/// .itemHeight(.estimated(44))
/// .insets(NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
/// ```
public struct List: CollectionSection {
  public let id: AnyHashable
  public let items: [any CollectionItem]
  var configuration = Configuration()

  // TODO: Make this not callable but still conformant somehow
  public func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: configuration.itemHeight)

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: itemSize,
      subitem: item,
      count: 1)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = configuration.insets
    section.contentInsetsReference = configuration.contentInsetsReference
    section.interGroupSpacing = 0

    return section
  }
}

extension List {
  /// Creates a list section with the specified items.
  ///
  /// - Parameters:
  ///   - id: A unique identifier for the section. Defaults to "list".
  ///   - items: A result builder closure that returns the items to display.
  public init(
    id: String = "list",
    @CollectionItemBuilder items: () -> [any CollectionItem])
  {
    self.id = id
    self.items = items()
  }
}

// MARK: - "ViewModifiers"

extension List {
  struct Configuration {
    var itemHeight: NSCollectionLayoutDimension = .estimated(100)
    var insets: NSDirectionalEdgeInsets = .zero
    var contentInsetsReference: UIContentInsetsReference = .automatic
  }

  /// Sets the height of items in the list.
  ///
  /// - Parameter dimension: The height dimension for items. Use `.estimated(_)` for dynamic heights
  ///   or `.absolute(_)` for fixed heights.
  /// - Returns: A list with the updated item height.
  public func itemHeight(_ dimension: NSCollectionLayoutDimension) -> Self {
    var copy = self
    copy.configuration.itemHeight = dimension
    return copy
  }

  /// Sets the content insets reference for the list.
  ///
  /// - Parameter contentInsetsReference: The reference for interpreting content insets.
  /// - Returns: A list with the updated content insets reference.
  public func contentInsetsReference(_ contentInsetsReference: UIContentInsetsReference) -> Self {
    var copy = self
    copy.configuration.contentInsetsReference = contentInsetsReference
    return copy
  }

  /// Sets the content insets for the list.
  ///
  /// - Parameter insets: The edge insets to apply to the section's content.
  /// - Returns: A list with the updated insets.
  public func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.configuration.insets = insets
    return copy
  }
}
#endif
