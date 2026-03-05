//
//  Grid.swift
//  DiffableUI
//
//  Created by Mauricio Cardozo on 3/5/26.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct Grid: CollectionSection {
    public let id: AnyHashable
    public let items: [any CollectionItem]
    var configuration = Configuration()
    
    public func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: configuration.itemHeight)
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = configuration.itemInsets
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: configuration.itemHeight)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = configuration.insets
        section.contentInsetsReference = configuration.contentInsetsReference
        section.interGroupSpacing = configuration.spacing
        
        return section
    }
}

extension Grid {
    public init(
        id: String = "grid",
        @CollectionItemBuilder items: () -> [any CollectionItem])
    {
        self.id = id
        self.items = items()
    }
}

// MARK: - "ViewModifiers"

extension Grid {
    struct Configuration {
        var columns: Int = 2
        var itemHeight: NSCollectionLayoutDimension = .estimated(100)
        var spacing: CGFloat = 0
        var insets: NSDirectionalEdgeInsets = .zero
        var itemInsets: NSDirectionalEdgeInsets = .zero
        var contentInsetsReference: UIContentInsetsReference = .automatic
    }
    
    public func columns(_ columns: Int) -> Self {
        var copy = self
        copy.configuration.columns = columns
        return copy
    }
    
    public func itemHeight(_ dimension: NSCollectionLayoutDimension) -> Self {
        var copy = self
        copy.configuration.itemHeight = dimension
        return copy
    }
    
    public func spacing(_ spacing: CGFloat) -> Self {
        var copy = self
        copy.configuration.spacing = spacing
        return copy
    }
    
    public func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
        var copy = self
        copy.configuration.insets = insets
        return copy
    }
    
    public func itemInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        var copy = self
        copy.configuration.itemInsets = insets
        return copy
    }
    
    public func contentInsetsReference(_ contentInsetsReference: UIContentInsetsReference) -> Self {
        var copy = self
        copy.configuration.contentInsetsReference = contentInsetsReference
        return copy
    }
}
#endif
