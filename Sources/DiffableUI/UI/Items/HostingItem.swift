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
@available(iOS 16.0, *)
public struct HostingItem<Content: View>: CollectionItem {
    public var id: AnyHashable
    public var item: AnyHashable { id }
    public var reuseIdentifier: String { "hosting-cell" }

    let content: Content
    let margins: EdgeInsets

    /// - Parameters:
    ///   - id: Identifies the item across reloads.
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
