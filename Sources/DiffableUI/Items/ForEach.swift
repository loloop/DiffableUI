//
//  ForEach.swift
//
//
//  Created by Mauricio Cardozo on 10/12/23.
//

#if canImport(UIKit)
import Foundation

extension CollectionItemBuilder {
  public static func buildExpression(_ expression: ForEach) -> [any CollectionItem] {
    expression.items
  }
}

public struct ForEach {
  public init<T>(data: [T], @CollectionItemBuilder items: (T) -> [any CollectionItem]) {
    self.items = data.map { items($0) }.flatMap { $0 }
  }

  let items: [any CollectionItem]
}

// TODO: ForEach Section
#endif
