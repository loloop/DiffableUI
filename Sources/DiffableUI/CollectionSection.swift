//
//  CollectionSection.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public protocol CollectionSection: Equatable {
  var id: AnyHashable { get }
  var items: [any CollectionItem] { get }
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

extension Array where Element == any CollectionSection {
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
