//
//  HostingItem.swift
//
//
//  Created by Mauricio Cardozo on 05/03/26.
//

#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

@available(iOS 16.0, *)
public struct HostingItem<Content: View>: CollectionItem {
    public var id: AnyHashable
    public var item: AnyHashable { id }
    public var reuseIdentifier: String { "hosting-cell" }

    let content: Content

    public init(id: AnyHashable = UUID(), @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }

    public func configure(cell: UICollectionViewCell) {
        cell.contentConfiguration = UIHostingConfiguration { content }
    }
    
    public func contextMenuConfiguration() -> UIContextMenuConfiguration? { nil }
}
#endif
