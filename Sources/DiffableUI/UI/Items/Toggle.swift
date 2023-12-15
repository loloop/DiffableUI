//
//  Toggle.swift
//
//
//  Created by Mauricio Cardozo on 11/12/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

// MARK: - Item

public struct Toggle: CollectionItem {
  
  // This is where bindings come in handy with SwiftUI
  public init(_ id: AnyHashable = UUID(), state: Bool) {
    self.id = id
    self.item = state
  }

  public var id: AnyHashable
  public var item: Bool
  public var reuseIdentifier: String { "toggle" }
  public func configure(cell: ToggleCell) {
    cell.isOn = item
    cell.onChange = { value in
      onChange?(value)
    }
  }

  var onChange: ((Bool) -> Void)?

  public func onChange(of state: @escaping (Bool) -> Void) -> Self {
    var copy = self
    copy.onChange = state
    return copy
  }
}

// MARK: - Cell

public final class ToggleCell: CollectionViewCell {

  public override func setUp() {
    super.setUp()
    contentView.directionalLayoutMargins = .zero
    setUpView()
  }

  public var isOn: Bool {
    get { toggle.isOn }
    set { toggle.isOn = newValue }
  }

  public var onChange: ((Bool) -> Void)?

  private let toggle = UISwitch()

  private func setUpView() {
    contentView.addSubview(toggle)
    toggle.center(in: contentView)
    toggle.addAction(
      UIAction(
        handler: { [weak self] _ in
            guard let self else { return }
            onChange?(toggle.isOn)
        }),
        for: .valueChanged)
  }
}
#endif
