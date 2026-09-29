//
//  OnAppearable.swift
//
//
//  Created by Mauricio Cardozo on 21/12/23.
//

#if canImport(UIKit)
import UIKit
import Foundation

public struct Taskable<T: CollectionItem>: CollectionItem {
  init(
    item: T,
    priority: TaskPriority?,
    action: @escaping @MainActor () async -> Void) {
    self._innerItem = item
    self.priority = priority
    self.action = action
  }

  let _innerItem: T
  let priority: TaskPriority?
  // Non-throwing on purpose: `onAppear(priority:action:onError:)` wraps throwing
  // actions with their handler, so no error can get lost in the task.
  let action: @MainActor () async -> Void

  public var id: AnyHashable {
    _innerItem.id
  }

  public var reuseIdentifier: String {
    _innerItem.reuseIdentifier + "-taskable"
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
    Task(priority: priority) { @MainActor in
      await action()
    }
  }
    
  public func contextMenuConfiguration() -> UIContextMenuConfiguration? {
    _innerItem.contextMenuConfiguration()
  }

  public func contextMenuPreviewParameters(for cell: T.CellType) -> UIPreviewParameters? {
    _innerItem.contextMenuPreviewParameters(for: cell)
  }
}

extension CollectionItem {
  /// Runs `action` in a new task each time the item's cell is about to be displayed,
  /// like SwiftUI's `task(priority:_:)`. It runs on the main actor, so it can update
  /// your view controller directly.
  ///
  /// The task isn't cancelled when the cell goes away, so capture `self` weakly.
  /// For an action that throws, use `onAppear(priority:action:onError:)`.
  public func onAppear(
    priority: TaskPriority? = nil,
    action: @escaping @MainActor () async -> Void) -> some CollectionItem
  {
    Taskable(item: self, priority: priority, action: action)
  }

  /// Runs a throwing `action` each time the item's cell is about to be displayed, and
  /// hands any error it throws to `onError`, so errors can't go unnoticed. Both run on
  /// the main actor, so `onError` can show the error right away:
  ///
  /// ```swift
  /// ActivityIndicator()
  ///   .onAppear { [weak self] in
  ///     try await self?.loadNextPage()
  ///   } onError: { [weak self] error in
  ///     self?.show(error)
  ///   }
  /// ```
  ///
  /// The task isn't cancelled when the cell goes away, so capture `self` weakly.
  /// Since DiffableUI never cancels it, a `CancellationError` only reaches `onError`
  /// when `action` throws one itself.
  public func onAppear(
    priority: TaskPriority? = nil,
    action: @escaping @MainActor () async throws -> Void,
    onError: @escaping @MainActor (any Error) -> Void) -> some CollectionItem
  {
    Taskable(item: self, priority: priority) {
      do {
        try await action()
      } catch {
        onError(error)
      }
    }
  }

  /// Makes a throwing action without an error handler a compile-time error that
  /// names the fix, instead of a generic type mismatch.
  @available(
    *,
    unavailable,
    message: "add an onError: handler for the errors this action throws, or catch them inside it")
  public func onAppear(
    priority: TaskPriority? = nil,
    action: @escaping @MainActor () async throws -> Void) -> Taskable<Self>
  {
    fatalError("unavailable")
  }
}
#endif
