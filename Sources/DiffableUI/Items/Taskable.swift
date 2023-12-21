//
//  OnAppearable.swift
//
//
//  Created by Mauricio Cardozo on 21/12/23.
//

#if canImport(UIKit)
import Foundation

public struct Taskable<T: CollectionItem>: CollectionItem {
  init(
    item: T,
    priority: TaskPriority?,
    action: @escaping () async throws -> Void) {
    self._innerItem = item
    self.priority = priority
    self.action = action
  }

  let _innerItem: T
  let priority: TaskPriority?
  let action: (() async throws -> Void)?

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
    _innerItem.didSelect()
  }

  public func setBehaviors(cell: T.CellType) {
    _innerItem.setBehaviors(cell: cell)
  }

  public func configure(cell: T.CellType) {
    _innerItem.configure(cell: cell)
  }

  public func willDisplay() {
    _innerItem.willDisplay()
    Task(priority: priority) {
      try await action?()
    }
  }
}

extension CollectionItem {
  public func onAppear(
    priority: TaskPriority? = nil,
    action: @escaping () async throws -> Void) -> some CollectionItem
  {
    Taskable(item: self, priority: priority, action: action)
  }
}
#endif
