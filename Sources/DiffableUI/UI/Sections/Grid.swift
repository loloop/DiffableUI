//
//  Grid.swift
//  DiffableUI
//
//  Created by Mauricio Cardozo on 3/5/26.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// A section that lays its items out in rows of equally wide columns.
///
/// By default the column count adapts to the available width, like SwiftUI's
/// `GridItem(.adaptive(minimum:spacing:))`: the grid fits as many columns of at
/// least ``minimumItemWidth(_:)`` points, ``spacing(_:)`` apart, as the width
/// inside its ``insets(_:)`` allows, then stretches them to fill the row. Use
/// ``columns(_:)`` for a fixed count instead.
///
/// ```swift
/// Grid {
///     ForEach(data: games) { game in
///         HostingItem(id: game.id) { GameCard(game) }
///     }
/// }
/// .minimumItemWidth(160)
/// .spacing(12)
/// .insets(.horizontal(16))
/// ```
@available(iOS 16.0, *)
public struct Grid: CollectionSection {
    public let id: AnyHashable
    public let items: [any CollectionItem]
    var configuration = Configuration()
    
    /// The number of columns laid out across a container `width` points wide,
    /// before ``insets(_:)``.
    ///
    /// A fixed ``columns(_:)`` count always wins. Otherwise this is how many
    /// columns of at least ``minimumItemWidth(_:)``, ``spacing(_:)`` apart, fit
    /// inside the insets, but never fewer than ``minimumColumns(_:)`` or 1.
    public func columnCount(fitting width: CGFloat) -> Int {
        if let fixed = configuration.columns {
            return max(1, fixed)
        }

        let minimumCount = max(1, configuration.minimumColumns)
        let spacing = configuration.spacing
        let columnStride = configuration.minimumItemWidth + spacing
        guard columnStride > 0 else { return minimumCount }

        // n columns fit when n * minimumItemWidth + (n - 1) * spacing <= usableWidth.
        let usableWidth = width - configuration.insets.leading - configuration.insets.trailing
        let fitting = Int(max(0, (usableWidth + spacing) / columnStride))
        return max(minimumCount, fitting)
    }

    public func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let columns = columnCount(fitting: environment.container.effectiveContentSize.width)

        // Half the spacing on each side of every item adds up to `spacing`
        // between neighbouring columns, and the section insets take the outer
        // halves back so the outermost items line up with `insets`.
        // (A repeating group keeps its item's width instead of dividing the
        // row, so `interItemSpacing` would overflow the row.)
        let halfSpacing = configuration.spacing / 2

        let itemHeight = configuration.itemHeight ?? .estimated(100)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: itemHeight)

        var itemInsets = configuration.itemInsets
        itemInsets.leading += halfSpacing
        itemInsets.trailing += halfSpacing

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemInsets

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: itemHeight)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: columns
        )
        
        var sectionInsets = configuration.insets
        sectionInsets.leading -= halfSpacing
        sectionInsets.trailing -= halfSpacing

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        section.contentInsetsReference = configuration.contentInsetsReference
        section.interGroupSpacing = configuration.spacing
        
        return section
    }
}

@available(iOS 16.0, *)
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

@available(iOS 16.0, *)
extension Grid {
    struct Configuration {
        var columns: Int? = nil
        var minimumItemWidth: CGFloat = 160
        var minimumColumns: Int = 1
        /// `nil` for the default, an estimated 100 points. UIKit only makes
        /// dimensions on the main actor, so `layout(environment:)` fills it in.
        var itemHeight: NSCollectionLayoutDimension?
        var spacing: CGFloat = 0
        var insets: NSDirectionalEdgeInsets = .zero
        var itemInsets: NSDirectionalEdgeInsets = .zero
        var contentInsetsReference: UIContentInsetsReference = .automatic
    }
    
    /// Lays the grid out in a fixed number of columns, overriding the adaptive
    /// count from ``minimumItemWidth(_:)`` and ``minimumColumns(_:)``.
    /// Pass `nil` to go back to an adaptive grid.
    public func columns(_ columns: Int?) -> Self {
        var copy = self
        copy.configuration.columns = columns
        return copy
    }

    /// The narrowest an item can get before the adaptive grid drops a column.
    /// Defaults to 160.
    public func minimumItemWidth(_ width: CGFloat) -> Self {
        var copy = self
        copy.configuration.minimumItemWidth = width
        return copy
    }
    
    /// The fewest columns the adaptive grid lays out, even when that makes
    /// items narrower than ``minimumItemWidth(_:)``. Defaults to 1.
    public func minimumColumns(_ columns: Int) -> Self {
        var copy = self
        copy.configuration.minimumColumns = columns
        return copy
    }

    public func itemHeight(_ dimension: NSCollectionLayoutDimension) -> Self {
        var copy = self
        copy.configuration.itemHeight = dimension
        return copy
    }
    
    /// The space between neighbouring columns and between rows. Defaults to 0.
    public func spacing(_ spacing: CGFloat) -> Self {
        var copy = self
        copy.configuration.spacing = spacing
        return copy
    }
    
    /// The space between the outermost items and the edges of the section,
    /// measured from the ``contentInsetsReference(_:)``.
    public func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
        var copy = self
        copy.configuration.insets = insets
        return copy
    }
    
    /// Extra insets inside every item, on top of ``spacing(_:)``.
    ///
    /// UIKit ignores insets along an estimated dimension, so `top` and
    /// `bottom` only apply with an absolute or fractional ``itemHeight(_:)``.
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
