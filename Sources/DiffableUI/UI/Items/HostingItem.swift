//
//  HostingItem.swift
//
//
//  Created by Mauricio Cardozo on 05/03/26.
//

#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

/// An item that renders SwiftUI content in its cell through `UIHostingConfiguration`.
///
/// The content fills the cell edge to edge, so the section's layout (such as
/// `Grid`'s `spacing` and `insets`) alone decides the space around it. Pass
/// `margins` to inset the content inside the cell instead.
///
/// Every reload reapplies the content to the item's visible cell, since SwiftUI views
/// can't be compared. The cell keeps its hosting view, so SwiftUI diffs the new content
/// into it and `@State` inside the content survives.
@available(iOS 16.0, *)
public struct HostingItem<Content: View>: CollectionItem {
    public var id: AnyHashable
    /// Unique to each instance, so a reload never mistakes new content for the old.
    public let item: AnyHashable = UUID()
    public var reuseIdentifier: String { "hosting-cell" }

    let content: Content
    let margins: EdgeInsets

    /// - Parameters:
    ///   - id: Identifies the item across reloads. Pass something stable, like your
    ///     model's id. The default, a new `UUID`, gives the item a new identity every
    ///     time `sections` is rebuilt, so each reload removes its cell and inserts a
    ///     new one instead of updating it.
    ///   - margins: Insets between the cell's edges and `content`. Defaults to none;
    ///     unlike a bare `UIHostingConfiguration`, the cell's layout margins aren't used.
    ///   - content: The SwiftUI view to display.
    public init(
        id: AnyHashable = UUID(),
        margins: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: () -> Content)
    {
        self.id = id
        self.margins = margins
        self.content = content()
    }

    public func configure(cell: UICollectionViewCell) {
        cell.contentConfiguration = UIHostingConfiguration { content }
            .margins(.all, margins)
    }
    
    public func contextMenuConfiguration() -> UIContextMenuConfiguration? { nil }
}
#endif
