#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit
import XCTest
@testable import DiffableUI

extension XCTestCase {
    /// Shows `controller` in a 440 × 956pt window (an iPhone Pro Max) and loads its sections.
    @MainActor
    func host(_ controller: DiffableViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 440, height: 956))
        window.rootViewController = controller
        window.isHidden = false
        controller.reload(animated: false)
        pumpLayout(window)
        return window
    }

    /// Runs layout passes, and the run loop between them so self-sizing cells and
    /// SwiftUI content settle, until `condition` holds or a second has passed.
    @MainActor
    func pumpLayout(_ window: UIWindow, until condition: () -> Bool = { false }) {
        let deadline = Date().addingTimeInterval(1)
        repeat {
            window.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        } while !condition() && Date() < deadline
        window.layoutIfNeeded()
    }

    @MainActor
    func cellFrames(in controller: DiffableViewController, count: Int) throws -> [CGRect] {
        try (0..<count).map { index in
            let cell = controller.collectionView.cellForItem(at: IndexPath(item: index, section: 0))
            return try XCTUnwrap(cell, "no cell for item \(index)").frame
        }
    }
}

@available(iOS 16.0, *)
final class SectionsViewController: DiffableViewController {
    init(@CollectionViewBuilder sections: @escaping () -> [any CollectionSection]) {
        makeSections = sections
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let makeSections: () -> [any CollectionSection]

    override var sections: [any CollectionSection] {
        makeSections()
    }
}

/// Collects the sizes SwiftUI content reports from inside its cells.
final class SizeProbe {
    var sizes: [Int: CGSize] = [:]
}
#endif
