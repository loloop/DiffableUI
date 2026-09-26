#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import XCTest
@testable import DiffableUI

@available(iOS 16.0, *)
final class ToggleTests: XCTestCase {
    @MainActor
    func testReloadUpdatesTheSameCell() throws {
        var isOn = false
        let controller = SectionsViewController {
            List {
                Toggle(id: "toggle", state: isOn)
            }
        }
        let window = host(controller)
        defer { window.isHidden = true }
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = try XCTUnwrap(controller.collectionView.cellForItem(at: indexPath) as? ToggleCell)
        XCTAssertFalse(cell.isOn)

        isOn = true
        controller.reload(animated: false)
        pumpLayout(window)
        XCTAssertIdentical(controller.collectionView.cellForItem(at: indexPath), cell)
        XCTAssertTrue(cell.isOn)
    }
}
#endif
