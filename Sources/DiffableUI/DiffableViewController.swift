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
    let oldValue = self.computedSections
    self.computedSections = sections

    updateAllVisibleItems(
      oldSections: oldValue,
      newSections: sections,
      collectionView: collectionView,
      dataSource: diffableDataSource)

    let shouldAnimate = animated && !oldValue.isEmpty && !computedSections.isEmpty

      diffableDataSource.apply(
        computedSections.snapshot,
        animatingDifferences: shouldAnimate,
        completion: completion)
  }

  @MainActor
  public func reload(animated: Bool = true, completion: (() -> Void)? = nil) async {
    let oldValue = self.computedSections
    self.computedSections = sections

    updateAllVisibleItems(
      oldSections: oldValue,
      newSections: sections,
      collectionView: collectionView,
      dataSource: diffableDataSource)

    let shouldAnimate = animated && !oldValue.isEmpty && !computedSections.isEmpty

    diffableDataSource.apply(
      computedSections.snapshot,
      animatingDifferences: shouldAnimate,
      completion: completion)
  }

  private func updateAllVisibleItems(
    oldSections: [any CollectionSection],
    newSections: [any CollectionSection],
    collectionView: UICollectionView,
    dataSource: UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>?)
  {
    let oldItems = oldSections.flatMap { $0.items }
    let newItems = newSections.flatMap { $0.items }

    for newItem in newItems {
      guard
        let oldItem = oldItems.first(where: { $0.id == newItem.id }),
        let indexPath = dataSource?.indexPath(for: AnyHashable(newItem))
      else {
        continue
      }

      if let cell = collectionView.cellForItem(at: indexPath) {
        if !newItem.isItemEqual(to: oldItem.item) {
          newItem.configureCell(cell)
        }
        newItem.setCellBehaviors(cell)
      }
    }
  }

  private(set) var computedSections = [any CollectionSection]()

  @CollectionViewBuilder
  open var sections: [any CollectionSection] {
    fatalError("Override this with @CollectionViewBuilder!")
  }

  private lazy var diffableDataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>(
    collectionView: collectionView,
    cellProvider: Self.cellProvider)

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

  private static func cellProvider(
    collectionView: UICollectionView,
    indexPath: IndexPath,
    item: AnyHashable)
    -> UICollectionViewCell
  {
    guard let collectionItem = item.base as? any CollectionItem else {
      return UICollectionViewCell()
    }
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
