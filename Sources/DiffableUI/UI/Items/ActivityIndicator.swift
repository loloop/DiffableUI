//
//  ActivityIndicator.swift
//
//
//  Created by Mauricio Cardozo on 11/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct ActivityIndicator: CollectionItem {
  public init() {}
  public var id: AnyHashable = UUID()
  public var item: AnyHashable { id }
  public var reuseIdentifier: String { "activity-indicator" }
  public func configure(cell: ActivityIndicatorCell) {
    cell.activityIndicator.startAnimating()
  }
}

public final class ActivityIndicatorCell: CollectionViewCell {
  public override func setUp() {
    super.setUp()
    contentView.directionalLayoutMargins = .zero
    setUpView()
  }

  let activityIndicator = UIActivityIndicatorView()

  func setUpView() {
    contentView.addSubview(activityIndicator)
    activityIndicator.center(in: contentView)
  }
}
#endif
