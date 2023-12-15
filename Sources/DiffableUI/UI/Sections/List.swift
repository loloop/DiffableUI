//
//  List.swift
//
//
//  Created by Mauricio Cardozo on 10/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct List: CollectionSection {
  public let id: AnyHashable
  public let items: [any CollectionItem]
  var configuration = Configuration()

  // TODO: Make this not callable but still conformant somehow
  public func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: configuration.itemHeight)

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: itemSize,
      subitem: item,
      count: 1)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = configuration.insets
    section.contentInsetsReference = configuration.contentInsetsReference
    section.interGroupSpacing = 0

    return section
  }
}

extension List {
  public init(
    id: String = "list",
    @CollectionItemBuilder items: () -> [any CollectionItem])
  {
    self.id = id
    self.items = items()
  }
}

// MARK: - "ViewModifiers"

extension List {
  struct Configuration {
    var itemHeight: NSCollectionLayoutDimension = .estimated(100)
    var insets: NSDirectionalEdgeInsets = .zero
    var contentInsetsReference: UIContentInsetsReference = .automatic
  }

  public func itemHeight(_ dimension: NSCollectionLayoutDimension) -> Self {
    var copy = self
    copy.configuration.itemHeight = dimension
    return copy
  }

  public func contentInsetsReference(_ contentInsetsReference: UIContentInsetsReference) -> Self {
    var copy = self
    copy.configuration.contentInsetsReference = contentInsetsReference
    return copy
  }

  public func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.configuration.insets = insets
    return copy
  }
}
#endif
