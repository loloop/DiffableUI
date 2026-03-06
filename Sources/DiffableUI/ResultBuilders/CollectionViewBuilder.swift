//
//  CollectionViewBuilder.swift
//
//
//  Created by Mauricio Cardozo on 07/12/23.
//

#if canImport(UIKit)
import Foundation

/// A result builder that enables declarative syntax for composing collection view sections.
///
/// `CollectionViewBuilder` allows you to build collection views using a SwiftUI-like
/// declarative syntax. It supports conditional statements, loops, and optional values.
///
/// ## Example
///
/// ```swift
/// @CollectionViewBuilder
/// var sections: [any CollectionSection] {
///     ListSection {
///         Text("Hello")
///     }
///     
///     if showGrid {
///         GridSection(columns: 2) {
///             ForEach(items) { item in
///                 ItemView(item: item)
///             }
///         }
///     }
/// }
/// ```
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
