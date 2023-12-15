//
//  Tappable.swift
//  
//
//  Created by Mauricio Cardozo on 11/12/23.
//
#if canImport(UIKit)
import Foundation

public struct Tappable<T: CollectionItem>: CollectionItem {
  init(item: T, action: @escaping () -> Void) {
    self._innerItem = item
    self._action = action
  }

  let _innerItem: T
  let _action: (() -> Void)?

  public var id: AnyHashable {
    _innerItem.id
  }

  public var reuseIdentifier: String {
    _innerItem.reuseIdentifier + "-tappable"
  }

  public var item: some Hashable {
    _innerItem.item
  }

  public func didSelect() {
    _action?()
  }

  public func setBehaviors(cell: T.CellType) {
    _innerItem.setBehaviors(cell: cell)
  }

  public func configure(cell: T.CellType) {
    _innerItem.configure(cell: cell)
  }
}

extension CollectionItem {
  public func onTap(_ action: @escaping () -> Void) -> some CollectionItem {
    Tappable(item: self, action: action)
  }
}
#endif
