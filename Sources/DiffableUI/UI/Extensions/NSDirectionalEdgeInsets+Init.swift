//
//  NSDirectionalEdgeInsets+Init.swift
//
//
//  Created by Mauricio Cardozo on 15/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension NSDirectionalEdgeInsets {

  public static func +=(lhs: inout NSDirectionalEdgeInsets, rhs: CGFloat) {
    lhs.top += rhs
    lhs.bottom += rhs
    lhs.leading += rhs
    lhs.trailing += rhs
  }

  public static func with(
    top: CGFloat = 0,
    leading: CGFloat = 0,
    bottom: CGFloat = 0,
    trailing: CGFloat = 0)
    -> NSDirectionalEdgeInsets
  {
    .init(
      top: top,
      leading: leading,
      bottom: bottom,
      trailing: trailing)
  }

  public static func all(_ value: CGFloat) -> NSDirectionalEdgeInsets {
    .init(
      top: value,
      leading: value,
      bottom: value,
      trailing: value)
  }

  public static func horizontal(_ value: CGFloat) -> NSDirectionalEdgeInsets {
    .init(
      top: 0,
      leading: value,
      bottom: 0,
      trailing: value)
  }

  public static func vertical(_ value: CGFloat) -> NSDirectionalEdgeInsets {
    .init(
      top: value,
      leading: 0,
      bottom: value,
      trailing: 0)
  }

  public func with(
    top: CGFloat? = nil,
    leading: CGFloat? = nil,
    bottom: CGFloat? = nil,
    trailing: CGFloat? = nil)
    -> NSDirectionalEdgeInsets
  {
    .init(
      top: top ?? self.top,
      leading: leading ?? self.leading,
      bottom: bottom ?? self.bottom,
      trailing: trailing ?? self.trailing)
  }

  public func horizontal(_ value: CGFloat?) -> NSDirectionalEdgeInsets {
    .init(
      top: top,
      leading: value ?? leading,
      bottom: bottom,
      trailing: value ?? trailing)
  }

  public func vertical(_ value: CGFloat?) -> NSDirectionalEdgeInsets {
    .init(
      top: value ?? top,
      leading: leading,
      bottom: value ?? bottom,
      trailing: trailing)
  }
}
#endif
