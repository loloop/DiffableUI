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
  /// `@MainActor` because UIKit's layout types are. Like `CollectionItem`'s cell
  /// requirements, an implementation declared with the conformance picks this up.
  @MainActor func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}

extension CollectionSection {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - Snapshot

/// Identifies a section or an item in the data source's snapshot.
///
/// The snapshot needs Sendable identifiers, and the `AnyHashable` ids of sections and
/// items aren't, so `SnapshotIDs` hands out a number for each id instead.
struct SnapshotID: Hashable, Sendable {
  let rawValue: Int
}

/// Numbers the sections and items of each reload for the data source's snapshot.
///
/// An id keeps the number it had in the previous reload, so the data source can tell
/// which sections and items stayed, moved or changed. Ids that are gone are forgotten.
struct SnapshotIDs {
  /// An item is the same across reloads when both its type and its id match, as it
  /// was when the snapshot held the items themselves. A different type needs a new cell.
  private struct ItemKey: Hashable {
    let type: ObjectIdentifier
    let id: AnyHashable

    init(_ item: any CollectionItem) {
      type = ObjectIdentifier(Swift.type(of: item))
      id = item.id
    }
  }

  /// The numbers from the previous reload.
  private var sectionIDs: [AnyHashable: SnapshotID] = [:]
  private var itemIDs: [ItemKey: SnapshotID] = [:]
  private var nextID = 0

  mutating func snapshot(of sections: [any CollectionSection]) -> NSDiffableDataSourceSnapshot<SnapshotID, SnapshotID> {
    var snapshot = NSDiffableDataSourceSnapshot<SnapshotID, SnapshotID>()
    var newSectionIDs: [AnyHashable: SnapshotID] = [:]
    var newItemIDs: [ItemKey: SnapshotID] = [:]

    // Repeated ids share a number, so the data source still rejects them as duplicates.
    for section in sections {
      let sectionID = newSectionIDs[section.id] ?? sectionIDs[section.id] ?? makeID()
      newSectionIDs[section.id] = sectionID
      snapshot.appendSections([sectionID])

      var sectionItemIDs = [SnapshotID]()
      for item in section.items {
        let key = ItemKey(item)
        let itemID = newItemIDs[key] ?? itemIDs[key] ?? makeID()
        newItemIDs[key] = itemID
        sectionItemIDs.append(itemID)
      }
      snapshot.appendItems(sectionItemIDs, toSection: sectionID)
    }

    sectionIDs = newSectionIDs
    itemIDs = newItemIDs
    return snapshot
  }

  private mutating func makeID() -> SnapshotID {
    defer { nextID += 1 }
    return SnapshotID(rawValue: nextID)
  }
}
#endif
