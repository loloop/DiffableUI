//
//  CollectionItem.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// A type that can be displayed in a collection view.
///
/// Types conforming to `CollectionItem` represent individual items that can be displayed
/// in a ``CollectionView``. Each item is responsible for configuring its own cell,
/// handling selection, and providing a unique identifier.
///
/// ## Conforming to CollectionItem
///
/// To create a custom collection item, define a type that conforms to `CollectionItem`
/// and implement the required properties and methods:
///
/// ```swift
/// struct CustomItem: CollectionItem {
///     typealias CellType = CustomCell
///     typealias ItemType = String
///     
///     let id = UUID()
///     let item: String
///     let reuseIdentifier = "CustomCell"
///     
///     func configure(cell: CustomCell) {
///         cell.label.text = item
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Required Properties
///
/// - ``id``
/// - ``item``
/// - ``cellClass``
/// - ``reuseIdentifier``
///
/// ### Configuration
///
/// - ``configure(cell:)``
/// - ``setBehaviors(cell:)``
///
/// ### Lifecycle
///
/// - ``didSelect()``
/// - ``willDisplay()``
public protocol CollectionItem: Equatable, Hashable, Identifiable {
  /// The type of cell used to display this item.
  associatedtype CellType: UICollectionViewCell
  
  /// The type of the underlying data this item represents.
  associatedtype ItemType: Hashable & Equatable
  
  /// A unique identifier for this item.
  ///
  /// This identifier is used by the diffable data source to track items
  /// and perform efficient updates.
  var id: AnyHashable { get }
  
  /// The underlying data this item represents.
  var item: ItemType { get }
  
  /// The class of the cell used to display this item.
  var cellClass: CellType.Type { get }
  
  /// The reuse identifier for the cell.
  ///
  /// This identifier is used to register and dequeue cells from the collection view.
  var reuseIdentifier: String { get }
  
  /// Configures the cell with this item's data.
  ///
  /// This method is called each time a cell needs to be configured for display.
  /// Implement this method to update the cell's UI with the item's data.
  ///
  /// - Parameter cell: The cell to configure.
  func configure(cell: CellType)
  
  /// Called when the item is selected.
  ///
  /// The default implementation does nothing. Override this method to handle
  /// selection events for your item.
  func didSelect()
  
  /// Sets up behaviors for the cell.
  ///
  /// This method is called once when the cell is first created. Use it to set up
  /// gesture recognizers, observers, or other behaviors that should persist
  /// across cell reuse.
  ///
  /// - Parameter cell: The cell to set up behaviors for.
  func setBehaviors(cell: CellType)
  
  /// Called when the item will be displayed.
  ///
  /// The default implementation does nothing. Override this method to perform
  /// actions when the item is about to be displayed, such as starting animations
  /// or loading data.
  func willDisplay()
}

// MARK: - Internal behavbiors & default conformances

extension CollectionItem {

  /// Default implementation does nothing.
  public func didSelect() {}

  /// Default implementation does nothing.
  public func setBehaviors(cell: CellType) {}

  /// Default implementation does nothing.
  public func willDisplay() {}

  /// Default implementation returns `CellType.self`.
  public var cellClass: CellType.Type {
    CellType.self
  }

  func configureCell(_ cell: UICollectionViewCell) {
    guard let innerCell = cell as? CellType else { return }
    configure(cell: innerCell)
  }

  func setCellBehaviors(_ cell: UICollectionViewCell) {
    guard let innerCell = cell as? CellType else { return }
    setBehaviors(cell: innerCell)
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
