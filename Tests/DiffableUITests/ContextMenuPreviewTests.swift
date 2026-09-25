#if canImport(UIKit)
import UIKit
import XCTest
@testable import DiffableUI

final class ContextMenuPreviewTests: XCTestCase {
    @MainActor
    func testItemsKeepUIKitsDefaultPreview() {
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let cell = LabelCell(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        XCTAssertNil(Label("Plain").contextMenuPreviewParametersForCell(cell))
        XCTAssertNil(Label("Menu").contextMenu(menu).contextMenuPreviewParametersForCell(cell))
    }

    @MainActor
    func testPaddedPreviewOutsetsTheCellThroughEveryWrapper() throws {
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let cell = LabelCell(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        let item = Label("Padded")
            .contextMenu(menu, previewPadding: 8, previewCornerRadius: 20)
            .onTap {}
            .onAppear {}
            .padding(.zero)
            .contextMenu(menu) // an outer menu without padding keeps the inner preview

        let parameters = try XCTUnwrap(item.contextMenuPreviewParametersForCell(cell))
        XCTAssertEqual(parameters.visiblePath?.bounds, CGRect(x: -8, y: -8, width: 116, height: 66))
    }
}
#endif
