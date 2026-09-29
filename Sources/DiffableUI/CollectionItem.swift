//
//  CollectionItem.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// Something to show in a cell.
///
/// The requirements that use the cell or respond to UIKit are `@MainActor`, since UIKit
/// calls them on the main thread. The protocol itself isn't, so `id`, `item` and
/// `Hashable` work anywhere. Implementations declared together with the conformance
/// pick up `@MainActor`, so `configure(cell:)` can use the cell directly.
public protocol CollectionItem: Equatable, Hashable, Identifiable {
  associatedtype CellType: UICollectionViewCell
  associatedtype ItemType: Hashable & Equatable
  var id: AnyHashable { get }
  var item: ItemType { get }
  var cellClass: CellType.Type { get }
  var reuseIdentifier: String { get }
  @MainActor func configure(cell: CellType)
  @MainActor func didSelect()
  @MainActor func setBehaviors(cell: CellType)
  @MainActor func willDisplay()
  @MainActor func contextMenuConfiguration() -> UIContextMenuConfiguration?
  /// How UIKit draws `cell` while its context menu is open: the lifted preview,
  /// and the one that animates back when the menu closes.
  /// Return `nil`, the default, to keep UIKit's default preview.
  @MainActor func contextMenuPreviewParameters(for cell: CellType) -> UIPreviewParameters?
}

// MARK: - Internal behaviors & default conformances

extension CollectionItem {

  @MainActor public func didSelect() {}

  @MainActor public func setBehaviors(cell: CellType) {}

  @MainActor public func willDisplay() {}

  @MainActor public func contextMenuConfiguration() -> UIContextMenuConfiguration? {
    nil
  }

  @MainActor public func contextMenuPreviewParameters(for cell: CellType) -> UIPreviewParameters? {
    nil
  }

  public var cellClass: CellType.Type {
    CellType.self
  }

  @MainActor func configureCell(_ cell: UICollectionViewCell) {
    guard let innerCell = cell as? CellType else { return }
    configure(cell: innerCell)
  }

  @MainActor func setCellBehaviors(_ cell: UICollectionViewCell) {
    guard let innerCell = cell as? CellType else { return }
    setBehaviors(cell: innerCell)
  }

  @MainActor func contextMenuPreviewParametersForCell(_ cell: UICollectionViewCell) -> UIPreviewParameters? {
    guard let innerCell = cell as? CellType else { return nil }
    return contextMenuPreviewParameters(for: innerCell)
  }

  func isItemEqual(to otherItem: any Hashable) -> Bool {
    return AnyHashable(item) == AnyHashable(otherItem)
  }
}

// MARK: - Hashable & Equatable

extension CollectionItem {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
#endif
