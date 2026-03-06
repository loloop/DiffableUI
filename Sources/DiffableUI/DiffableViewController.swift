//
//  DiffableViewController.swift
//
//
//  Created by Mauricio Cardozo on 08/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// A view controller that manages a collection view with diffable data source.
///
/// `DiffableViewController` provides a declarative way to build collection views
/// using compositional layouts and diffable data sources. Subclass this controller
/// and override the ``sections`` property to define your collection view content.
///
/// ## Overview
///
/// The view controller automatically handles:
/// - Setting up the diffable data source
/// - Configuring the compositional layout
/// - Managing cell registration and dequeuing
/// - Handling item selection and display callbacks
/// - Performing efficient updates with animations
///
/// ## Example
///
/// ```swift
/// class MyViewController: DiffableViewController {
///     @CollectionViewBuilder
///     override var sections: [any CollectionSection] {
///         ListSection {
///             Text("Hello, World!")
///             Button("Tap me") {
///                 print("Button tapped")
///             }
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Creating a View Controller
///
/// - ``init(configuration:)``
///
/// ### Defining Content
///
/// - ``sections``
///
/// ### Updating Content
///
/// - ``reload(animated:completion:)``
/// - ``reload(animated:completion:)-4jmid``
open class DiffableViewController: UICollectionViewController {

  /// Creates a new diffable view controller.
  ///
  /// - Parameter configuration: The compositional layout configuration to use.
  ///   The default configuration has no special behavior.
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

  /// Reloads the collection view with the current sections.
  ///
  /// This method recalculates the sections from the ``sections`` property and
  /// applies the changes to the collection view using the diffable data source.
  ///
  /// - Parameters:
  ///   - animated: Whether to animate the changes. Defaults to `true`.
  ///   - completion: A closure to execute after the reload completes.
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

  /// Asynchronously reloads the collection view with the current sections.
  ///
  /// This method recalculates the sections from the ``sections`` property and
  /// applies the changes to the collection view using the diffable data source.
  ///
  /// - Parameters:
  ///   - animated: Whether to animate the changes. Defaults to `true`.
  ///   - completion: A closure to execute after the reload completes.
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

  /// The sections to display in the collection view.
  ///
  /// Override this property in your subclass and use the `@CollectionViewBuilder`
  /// attribute to define your collection view content declaratively.
  ///
  /// ```swift
  /// @CollectionViewBuilder
  /// override var sections: [any CollectionSection] {
  ///     ListSection {
  ///         Text("Item 1")
  ///         Text("Item 2")
  ///     }
  ///     
  ///     GridSection(columns: 2) {
  ///         for i in 0..<10 {
  ///             Text("Grid item \(i)")
  ///         }
  ///     }
  /// }
  /// ```
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

  /// Handles item selection.
  ///
  /// This method is called when an item is selected and forwards the event
  /// to the item's ``CollectionItem/didSelect()`` method.
  public override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath)
  {
    let item = computedSections[indexPath.section].items[indexPath.row]
    item.didSelect()
  }

  /// Handles cell display events.
  ///
  /// This method is called when a cell is about to be displayed and forwards
  /// the event to the item's ``CollectionItem/willDisplay()`` method.
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
