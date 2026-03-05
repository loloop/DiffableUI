//
//  ContextMenu.swift
//
//
//  Created by Mauricio Cardozo on 05/03/26.
//

#if canImport(UIKit)
import UIKit

public struct ContextMenu<T: CollectionItem>: CollectionItem {
  init(item: T, menu: UIMenu) {
    self._innerItem = item
    self._menu = menu
  }

  let _innerItem: T
  let _menu: UIMenu

  public var id: AnyHashable { _innerItem.id }
  public var reuseIdentifier: String { _innerItem.reuseIdentifier }
  public var item: some Hashable { _innerItem.item }

  public func configure(cell: T.CellType) { _innerItem.configure(cell: cell) }
  public func didSelect() { _innerItem.didSelect() }
  public func setBehaviors(cell: T.CellType) { _innerItem.setBehaviors(cell: cell) }
  public func willDisplay() { _innerItem.willDisplay() }
  public func contextMenuConfiguration() -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(actionProvider: { [_menu] _ in _menu })
  }
}

extension CollectionItem {
  public func contextMenu(_ menu: UIMenu) -> some CollectionItem {
    ContextMenu(item: self, menu: menu)
  }
}
#endif
