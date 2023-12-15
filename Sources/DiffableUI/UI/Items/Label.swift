//
//  Label.swift
//
//
//  Created by Mauricio Cardozo on 08/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

// MARK: - Declaration

public struct Label: CollectionItem {
  public init(_ text: String) {
    item = text
  }

  public var id: AnyHashable { item }
  public var item: String
  public var reuseIdentifier: String { "label-cell" }
  public func configure(cell: LabelCell) {
    cell.text = item
    configure(cell: cell, configuration: configuration)
  }

  var configuration = Configuration()
}

// MARK: - Configuration

extension Label {
  struct Configuration {
    var alignment: NSTextAlignment = .natural
    var textColor: UIColor = .label
    var fontStyle: UIFont.TextStyle = .body
  }

  func configure(cell: LabelCell, configuration: Configuration) {
    cell.textAlignment = configuration.alignment
    cell.textColor = configuration.textColor
    cell.setFontStyle(configuration.fontStyle)
  }

  public func textAlignment(_ alignment: NSTextAlignment) -> Self {
    var copy = self
    copy.configuration.alignment = alignment
    return copy
  }

  public func textColor(_ color: UIColor) -> Self {
    var copy = self
    copy.configuration.textColor = color
    return copy
  }

  public func fontStyle(_ style: UIFont.TextStyle) -> Self {
    var copy = self
    copy.configuration.fontStyle = style
    return copy
  }
}

// MARK: - CollectionViewCell

public final class LabelCell: CollectionViewCell {

  override public func setUp() {
    super.setUp()
    setUpViews()
    setUpConstraints()
  }

  public var text: String? {
    get { label.text }
    set { label.text = newValue }
  }

  public var textAlignment: NSTextAlignment {
    get { label.textAlignment }
    set { label.textAlignment = newValue }
  }

  public var textColor: UIColor? {
    get { label.textColor }
    set { label.textColor = newValue }
  }

  public func setFontStyle(_ style: UIFont.TextStyle) {
    label.font = .preferredFont(forTextStyle: style)
  }

  private let label = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  private func setUpViews() {
    contentView.addSubview(label)
    contentView.directionalLayoutMargins = .zero
  }

  private func setUpConstraints() {
    label.constrainToLayoutMargins(of: contentView)
  }
}
#endif
