//
//  CollectionViewBuilder.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation

@resultBuilder
public struct CollectionViewBuilder {
  public static func buildBlock(_ components: any CollectionSection...) -> [any CollectionSection] {
    components
  }

  public static func buildExpression(_ expression: any CollectionSection) -> [any CollectionSection] {
    [expression]
  }

  public static func buildExpression(_ expression: [any CollectionSection]) -> [any CollectionSection] {
    expression
  }

  public static func buildExpression(_ expression: Never) -> [any CollectionSection] {}

  public static func buildBlock(_ components: [any CollectionSection]...) -> [any CollectionSection] {
    components.flatMap { $0 }
  }

  public static func buildOptional(_ component: [any CollectionSection]?) -> [any CollectionSection] {
    component ?? []
  }

  public static func buildEither(first component: [any CollectionSection]) -> [any CollectionSection] {
    component
  }

  public static func buildEither(second component: [any CollectionSection]) -> [any CollectionSection] {
    component
  }

  public static func buildArray(_ components: [[any CollectionSection]]) -> [any CollectionSection] {
    components.flatMap { $0 }
  }

  public static func buildLimitedAvailability(_ component: [any CollectionSection]) -> [any CollectionSection] {
    component
  }
}
#endif
