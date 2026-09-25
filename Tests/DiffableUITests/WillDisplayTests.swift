#if canImport(UIKit)
import UIKit
import XCTest
@testable import DiffableUI

final class WillDisplayTests: XCTestCase {
    @MainActor
    func testOnAppearRunsThroughEveryWrapper() {
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let appeared = expectation(description: "onAppear runs")
        let item = Label("Wrapped")
            .onAppear { appeared.fulfill() }
            .onTap {}
            .padding(.zero)
            .contextMenu(menu)

        item.willDisplay()

        wait(for: [appeared], timeout: 1)
    }
}
#endif
