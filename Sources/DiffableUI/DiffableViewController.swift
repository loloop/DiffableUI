//
//  DiffableViewController.swift
//
//
//  Created by Mauricio Cardozo on 08/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

open class DiffableViewController: UICollectionViewController {

  public init(configuration: UICollectionViewCompositionalLayoutConfiguration = .init()) {
    layout = CollectionViewControllerLayout(configuration: configuration)
    super.init(collectionViewLayout: layout.compositionalLayout)
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }

  private func setUp() {
    collectionView.dataSource = diffableDataSource
    collectionView.delegate = self
    collectionView.directionalLayoutMargins = .zero

    // TODO: Add a way to configure our CollectionView

    setUpLayout()
  }

  private let layout: CollectionViewControllerLayout

  public func reload(animated: Bool = true, completion: (() -> Void)? = nil) {
    apply(sections, animated: animated, completion: completion)
  }

  @MainActor
  public func reload(animated: Bool = true, completion: (() -> Void)? = nil) async {
    apply(sections, animated: animated, completion: completion)
  }

  private func apply(
    _ newSections: [any CollectionSection],
    animated: Bool,
    completion: (() -> Void)?)
  {
    let oldSections = computedSections
    computedSections = newSections
    let snapshot = snapshotIDs.snapshot(of: newSections)

    updateAllVisibleItems(
      oldSections: oldSections,
      newSections: newSections,
      newSnapshot: snapshot)

    let shouldAnimate = animated && !oldSections.isEmpty && !newSections.isEmpty

    diffableDataSource.apply(
      snapshot,
      animatingDifferences: shouldAnimate,
      completion: completion)
  }

  /// Reconfigures the visible cells whose item changed, since the data source only
  /// asks for the cells it inserts. Runs before `newSnapshot` is applied, while the
  /// data source still has each identifier at its item's index path in `oldSections`.
  private func updateAllVisibleItems(
    oldSections: [any CollectionSection],
    newSections: [any CollectionSection],
    newSnapshot: NSDiffableDataSourceSnapshot<SnapshotID, SnapshotID>)
  {
    let newItems = newSections.flatMap { $0.items }

    for (newItem, itemID) in zip(newItems, newSnapshot.itemIdentifiers) {
      guard
        let indexPath = diffableDataSource.indexPath(for: itemID),
        let cell = collectionView.cellForItem(at: indexPath)
      else {
        continue
      }

      let oldItem = oldSections[indexPath.section].items[indexPath.row]
      if !newItem.isItemEqual(to: oldItem.item) {
        newItem.configureCell(cell)
      }
      newItem.setCellBehaviors(cell)
    }
  }

  private(set) var computedSections = [any CollectionSection]()

  private var snapshotIDs = SnapshotIDs()

  @CollectionViewBuilder
  open var sections: [any CollectionSection] {
    fatalError("Override this with @CollectionViewBuilder!")
  }

  private lazy var diffableDataSource = UICollectionViewDiffableDataSource<SnapshotID, SnapshotID>(
    collectionView: collectionView,
    cellProvider: { [weak self] collectionView, indexPath, _ in
      self?.cell(in: collectionView, at: indexPath) ?? UICollectionViewCell()
    })

  private func setUpLayout() {
    layout.sectionProvider = { [weak self] index, layoutEnvironment in
      guard let self = self else {
        return nil
      }

      return self.computedSections[index].layout(environment: layoutEnvironment)
    }
  }

  public override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath)
  {
    let item = computedSections[indexPath.section].items[indexPath.row]
    item.didSelect()
  }

  public override func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    let item = computedSections[indexPath.section].items[indexPath.row]
    item.willDisplay()
  }

  public override func collectionView(
    _ collectionView: UICollectionView,
    contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
    point: CGPoint) -> UIContextMenuConfiguration?
  {
    guard let indexPath = indexPaths.first else { return nil }
    let item = computedSections[indexPath.section].items[indexPath.row]
    return item.contextMenuConfiguration()
  }

  open override func collectionView(
    _ collectionView: UICollectionView,
    contextMenuConfiguration configuration: UIContextMenuConfiguration,
    highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview?
  {
    contextMenuPreview(forItemAt: indexPath, in: collectionView)
  }

  open override func collectionView(
    _ collectionView: UICollectionView,
    contextMenuConfiguration configuration: UIContextMenuConfiguration,
    dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview?
  {
    contextMenuPreview(forItemAt: indexPath, in: collectionView)
  }

  /// The cell's preview drawn with its item's `contextMenuPreviewParameters(for:)`,
  /// or `nil`, which tells UIKit to use its default preview.
  private func contextMenuPreview(
    forItemAt indexPath: IndexPath,
    in collectionView: UICollectionView) -> UITargetedPreview?
  {
    guard
      computedSections.indices.contains(indexPath.section),
      computedSections[indexPath.section].items.indices.contains(indexPath.row),
      let cell = collectionView.cellForItem(at: indexPath),
      cell.window != nil
    else {
      return nil
    }

    let item = computedSections[indexPath.section].items[indexPath.row]
    guard let parameters = item.contextMenuPreviewParametersForCell(cell) else {
      return nil
    }
    return UITargetedPreview(view: cell, parameters: parameters)
  }

  /// The data source's cell provider. The snapshot only holds identifiers, so the
  /// item comes from `computedSections`, which is assigned before each snapshot built
  /// from it is applied. Their index paths match.
  private func cell(
    in collectionView: UICollectionView,
    at indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let collectionItem = computedSections[indexPath.section].items[indexPath.row]
    collectionView.register(
      collectionItem.cellClass,
      forCellWithReuseIdentifier: collectionItem.reuseIdentifier)

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: collectionItem.reuseIdentifier,
      for: indexPath)

    collectionItem.configureCell(cell)
    collectionItem.setCellBehaviors(cell)
    return cell
  }
}

@MainActor
final class CollectionViewControllerLayout {

  init(configuration: UICollectionViewCompositionalLayoutConfiguration) {
    self.configuration = configuration
  }

  var compositionalLayout: UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout(
      sectionProvider: { [weak self] index, layoutEnvironment in
        self?.sectionProvider?(index, layoutEnvironment)
      },
      configuration: configuration)
  }

  var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider?

  private let configuration: UICollectionViewCompositionalLayoutConfiguration
}
#endif
