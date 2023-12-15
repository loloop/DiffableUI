//
//  CollectionViewCell.swift
//
//
//  Created by Mauricio Cardozo on 11/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

open class CollectionViewCell: UICollectionViewCell {

  override public init(frame: CGRect) {
    super.init(frame: frame)

    setUp()
  }

  @available(*, unavailable)
  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func setUp() {
    directionalLayoutMargins = .zero
    contentView.constrainToLayoutMargins(of: self)
  }
}
#endif
