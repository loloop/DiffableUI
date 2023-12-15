//
//  Padding.swift
//  
//
//  Created by Mauricio Cardozo on 15/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct Padding<T: CollectionItem>: CollectionItem {
  init(item: T, padding: NSDirectionalEdgeInsets) {
    self._innerItem = item
    self.insets = padding
  }

  let _innerItem: T
  let insets: NSDirectionalEdgeInsets

  public var id: AnyHashable {
    _innerItem.id
  }

  public var reuseIdentifier: String {
    _innerItem.reuseIdentifier + "-paddable"
  }

  public var item: some Hashable {
    _innerItem.item
  }

  public func didSelect() {
    _innerItem.didSelect()
  }

  public func setBehaviors(cell: T.CellType) {
    _innerItem.setBehaviors(cell: cell)
  }

  public func configure(cell: T.CellType) {
    if let innerCell = cell as? CollectionViewCell {
      innerCell.directionalLayoutMargins = insets
    }

    _innerItem.configure(cell: cell)
  }
}

extension CollectionItem {
  public func padding(_ insets: NSDirectionalEdgeInsets) -> some CollectionItem {
    Padding(item: self, padding: insets)
  }
}
#endif
