#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit
import XCTest
@testable import DiffableUI

/// Reloads a `HostingItem` under the same `id` and checks that its cell shows the new content.
@available(iOS 17.0, *)
final class HostingItemUpdateTests: XCTestCase {
    @MainActor
    func testVisibleCellShowsNewContent() {
        let model = Model()
        let controller = SectionsViewController {
            List {
                HostingItem(id: "game") { TitleView(title: model.title, probe: model) }
            }
        }
        let window = host(controller)
        defer { window.isHidden = true }
        pumpLayout(window, until: { model.shownTitle == "Old" })
        XCTAssertEqual(model.shownTitle, "Old")

        model.title = "New"
        controller.reload(animated: false)
        pumpLayout(window, until: { model.shownTitle == "New" })
        XCTAssertEqual(model.shownTitle, "New")
    }

    @MainActor
    func testVisibleCellShowsNewContentThroughWrappers() {
        let model = Model()
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let controller = SectionsViewController {
            List {
                HostingItem(id: "game") { TitleView(title: model.title, probe: model) }
                    .contextMenu(menu)
                    .onTap {}
            }
        }
        let window = host(controller)
        defer { window.isHidden = true }
        pumpLayout(window, until: { model.shownTitle == "Old" })

        model.title = "New"
        controller.reload(animated: false)
        pumpLayout(window, until: { model.shownTitle == "New" })
        XCTAssertEqual(model.shownTitle, "New")
    }

    @MainActor
    func testVisibleCellAppliesNewMargins() throws {
        let probe = SizeProbe()
        var margins = EdgeInsets()
        let controller = SectionsViewController {
            Grid {
                HostingItem(id: 0, margins: margins) {
                    Color.blue
                        .frame(height: 100)
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.sizes[0] = $0 }
                }
            }
            .columns(1)
        }
        let window = host(controller)
        defer { window.isHidden = true }
        pumpLayout(window, until: { probe.sizes[0]?.width == 440 })
        XCTAssertEqual(probe.sizes[0]?.width, 440)

        margins = EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        controller.reload(animated: false)
        pumpLayout(window, until: { probe.sizes[0]?.width == 440 - 16 })
        let frame = try XCTUnwrap(cellFrames(in: controller, count: 1).first)
        let content = try XCTUnwrap(probe.sizes[0])
        XCTAssertEqual(content.width, frame.width - 16, accuracy: 0.01)
        XCTAssertEqual(content.height, frame.height - 16, accuracy: 0.01)
    }

    @MainActor
    func testOffscreenCellShowsNewContentWhenScrolledBack() throws {
        let model = Model()
        let controller = SectionsViewController {
            List {
                HostingItem(id: "game") { TitleView(title: model.title, probe: model) }
                for index in 0..<10 {
                    HostingItem(id: index) { Color.blue }
                }
            }
            .itemHeight(.absolute(300))
        }
        let window = host(controller)
        defer { window.isHidden = true }
        pumpLayout(window, until: { model.shownTitle == "Old" })

        // Without prefetching, UIKit reuses the scrolled-away cell instead of keeping it
        // prepared, so scrolling back configures a cell from the latest snapshot.
        let collectionView = try XCTUnwrap(controller.collectionView)
        collectionView.isPrefetchingEnabled = false
        let bottom = collectionView.contentSize.height - collectionView.bounds.height
        collectionView.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
        pumpLayout(window)
        XCTAssertNil(collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))

        model.title = "New"
        controller.reload(animated: false)
        collectionView.setContentOffset(.zero, animated: false)
        pumpLayout(window, until: { model.shownTitle == "New" })
        XCTAssertEqual(model.shownTitle, "New")
    }

    @MainActor
    func testReloadKeepsTheContentsSwiftUIState() {
        let model = Model()
        let controller = SectionsViewController {
            List {
                HostingItem(id: "game") { TitleView(title: model.title, probe: model) }
            }
        }
        let window = host(controller)
        defer { window.isHidden = true }
        pumpLayout(window, until: { model.appearances == 1 })

        model.title = "New"
        controller.reload(animated: false)
        pumpLayout(window, until: { model.shownTitle == "New" })
        XCTAssertEqual(model.appearances, 1, "the cell's hosting view updates in place instead of being replaced")
    }
}

@available(iOS 17.0, *)
private final class Model {
    var title = "Old"
    var shownTitle: String?
    var appearances = 0
}

/// Reports the title it renders, so tests can tell what the cell shows.
@available(iOS 17.0, *)
private struct TitleView: View {
    let title: String
    let probe: Model

    var body: some View {
        Text(title)
            .onChange(of: title, initial: true) { probe.shownTitle = title }
            .onAppear { probe.appearances += 1 }
    }
}
#endif
