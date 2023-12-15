//
//  UIView+Constraints.swift
//
//
//  Created by Mauricio Cardozo on 17/07/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension UIView {

  @discardableResult
  func constrainVertically(to layoutGuide: UILayoutGuide) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
    ])
    return self
  }

  @discardableResult
  func constrainVertically(to view: UIView) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    return self
  }

  @discardableResult
  func constrainHorizontally(to layoutGuide: UILayoutGuide) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
    ])
    return self
  }

  @discardableResult
  func constrainHorizontally(to view: UIView) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    return self
  }

  func constrainToLayoutMargins(of view: UIView) {
    let margins = view.layoutMarginsGuide
    constrainVertically(to: margins)
      .constrainHorizontally(to: margins)
  }

  func constrainToEdges(of view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor),
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  func center(in view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: view.centerXAnchor),
      centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  @discardableResult
  func constrainHeightTo(_ height: CGFloat) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: height),
    ])
    return self
  }

  @discardableResult
  func constrainWidthTo(_ width: CGFloat) -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: width),
    ])
    return self
  }

  func constrainTo(size: CGSize) {
    constrainHeightTo(size.width)
      .constrainWidthTo(size.height)
  }
}
#endif
