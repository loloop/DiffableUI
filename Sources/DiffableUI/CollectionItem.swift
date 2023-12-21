//
//  CollectionItem.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

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

// MARK: - Internal behavbiors & default conformances

extension CollectionItem {

  public func didSelect() {}

  public func setBehaviors(cell: CellType) {}

  public func willDisplay() {}

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
