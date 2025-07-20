//
//  CollectionSection.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// A type that represents a section in a collection view.
///
/// Types conforming to `CollectionSection` define how a group of ``CollectionItem``
/// instances are laid out in a collection view. Each section provides its own
/// compositional layout configuration.
///
/// ## Conforming to CollectionSection
///
/// To create a custom section, define a type that conforms to `CollectionSection`
/// and implement the required properties and methods:
///
/// ```swift
/// struct CustomSection: CollectionSection {
///     let id = UUID()
///     let items: [any CollectionItem]
///     
///     func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
///         let itemSize = NSCollectionLayoutSize(
///             widthDimension: .fractionalWidth(1.0),
///             heightDimension: .estimated(44)
///         )
///         let item = NSCollectionLayoutItem(layoutSize: itemSize)
///         
///         let groupSize = NSCollectionLayoutSize(
///             widthDimension: .fractionalWidth(1.0),
///             heightDimension: .estimated(44)
///         )
///         let group = NSCollectionLayoutGroup.horizontal(
///             layoutSize: groupSize,
///             subitems: [item]
///         )
///         
///         return NSCollectionLayoutSection(group: group)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Required Properties
///
/// - ``id``
/// - ``items``
///
/// ### Layout
///
/// - ``layout(environment:)``
public protocol CollectionSection: Equatable {
  /// A unique identifier for this section.
  ///
  /// This identifier is used by the diffable data source to track sections
  /// and perform efficient updates.
  var id: AnyHashable { get }
  
  /// The items contained in this section.
  var items: [any CollectionItem] { get }
  
  /// Creates the compositional layout for this section.
  ///
  /// This method is called when the collection view needs to determine how to
  /// lay out the items in this section. The layout environment provides information
  /// about the current trait collection and container size.
  ///
  /// - Parameter environment: The layout environment containing trait collection
  ///   and container information.
  /// - Returns: A compositional layout section configuration.
  func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}

extension CollectionSection {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

/// Extension providing snapshot generation for arrays of sections.
extension Array where Element == any CollectionSection {
  /// Generates a diffable data source snapshot from the sections.
  ///
  /// This property creates a snapshot that can be applied to a diffable data source,
  /// mapping sections and their items to the appropriate identifiers.
  var snapshot: NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable> {
    var diffableSnapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>()
    self.forEach { section in
      diffableSnapshot.appendSections([section.id])
      diffableSnapshot.appendItems(section.items.map { AnyHashable($0) }, toSection: section.id)
    }
    return diffableSnapshot
  }
}
#endif
