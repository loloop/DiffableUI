//
//  ContextMenu.swift
//
//
//  Created by Mauricio Cardozo on 05/03/26.
//

#if canImport(UIKit)
import UIKit

public struct ContextMenu<T: CollectionItem>: CollectionItem {
  init(item: T, menu: UIMenu, previewPadding: CGFloat?, previewCornerRadius: CGFloat) {
    self._innerItem = item
    self._menu = menu
    self._previewPadding = previewPadding
    self._previewCornerRadius = previewCornerRadius
  }

  let _innerItem: T
  let _menu: UIMenu
  let _previewPadding: CGFloat?
  let _previewCornerRadius: CGFloat

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

  public func contextMenuPreviewParameters(for cell: T.CellType) -> UIPreviewParameters? {
    guard let padding = _previewPadding else {
      return _innerItem.contextMenuPreviewParameters(for: cell)
    }
    let parameters = UIPreviewParameters()
    parameters.visiblePath = UIBezierPath(
      roundedRect: cell.bounds.insetBy(dx: -padding, dy: -padding),
      cornerRadius: _previewCornerRadius)
    return parameters
  }
}

extension CollectionItem {
  /// Shows `menu` when the item is long-pressed.
  ///
  /// - Parameters:
  ///   - menu: The menu to show.
  ///   - previewPadding: Room around the cell in the lifted preview, useful when the
  ///     cell's content runs edge to edge, like a `HostingItem` in a `Grid`.
  ///     `nil`, the default, keeps UIKit's default preview.
  ///   - previewCornerRadius: The corner radius of the padded preview. For corners
  ///     concentric with content rounded by `r`, pass `r + previewPadding`.
  ///     Ignored when `previewPadding` is `nil`.
  public func contextMenu(
    _ menu: UIMenu,
    previewPadding: CGFloat? = nil,
    previewCornerRadius: CGFloat = 0) -> some CollectionItem
  {
    ContextMenu(
      item: self,
      menu: menu,
      previewPadding: previewPadding,
      previewCornerRadius: previewCornerRadius)
  }
}
#endif
