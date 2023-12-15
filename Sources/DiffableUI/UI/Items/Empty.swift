//
//  Empty.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct Empty: CollectionItem {
  public init() {}
  public var id: AnyHashable { item.id }
  public var item = EmptyHashable()
  public var reuseIdentifier: String { "empty" }
  public func configure(cell: UICollectionViewCell) {}

  public struct EmptyHashable: Hashable {
    let id = UUID()
  }
}
#endif
