#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit
import XCTest
@testable import DiffableUI

/// Lays grids out in a 440 × 956pt window (an iPhone Pro Max) and measures the cells.
@available(iOS 16.0, *)
final class GridLayoutTests: XCTestCase {
    @MainActor
    func testSpacingSeparatesColumnsAndRows() throws {
        let controller = SectionsViewController {
            Grid {
                for index in 0..<4 {
                    HostingItem(id: index) { Color.blue.frame(height: 100) }
                }
            }
            .minimumItemWidth(160)
            .spacing(12)
        }
        let window = host(controller)
        defer { window.isHidden = true }

        let frames = try cellFrames(in: controller, count: 4)
        XCTAssertEqual(frames[0].minX, 0, accuracy: 0.01, "no inset at the leading edge")
        XCTAssertEqual(frames[1].maxX, 440, accuracy: 0.01, "no inset at the trailing edge")
        XCTAssertEqual(frames[1].minX - frames[0].maxX, 12, accuracy: 0.01, "space between columns")
        XCTAssertEqual(frames[2].minY - frames[0].maxY, 12, accuracy: 0.01, "space between rows")
        XCTAssertEqual(frames[0].width, 214, accuracy: 0.01)
        XCTAssertEqual(frames[1].width, 214, accuracy: 0.01)
    }

    @MainActor
    func testInsetsAndItemInsetsAddToTheSpacing() throws {
        let controller = SectionsViewController {
            Grid {
                for index in 0..<4 {
                    HostingItem(id: index) { Color.blue.frame(height: 100) }
                }
            }
            .minimumItemWidth(160)
            .spacing(12)
            .insets(.horizontal(16))
            .itemInsets(.horizontal(4))
        }
        let window = host(controller)
        defer { window.isHidden = true }

        let frames = try cellFrames(in: controller, count: 4)
        XCTAssertEqual(frames[0].minX, 16 + 4, accuracy: 0.01)
        XCTAssertEqual(440 - frames[1].maxX, 16 + 4, accuracy: 0.01)
        XCTAssertEqual(frames[1].minX - frames[0].maxX, 4 + 12 + 4, accuracy: 0.01)
        XCTAssertEqual(frames[2].minY - frames[0].maxY, 12, accuracy: 0.01)
    }

    @MainActor
    func testHostingItemContentFillsTheCell() throws {
        let probe = SizeProbe()
        let controller = SectionsViewController {
            Grid {
                for index in 0..<2 {
                    HostingItem(id: index) {
                        Color.blue
                            .frame(height: 100)
                            .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.sizes[index] = $0 }
                    }
                }
            }
            .spacing(12)
        }
        let window = host(controller)
        defer { window.isHidden = true }

        pumpLayout(window, until: { probe.sizes.count == 2 })
        let frames = try cellFrames(in: controller, count: 2)
        for index in 0..<2 {
            let content = try XCTUnwrap(probe.sizes[index], "item \(index) never measured its content")
            XCTAssertEqual(content.width, frames[index].width, accuracy: 0.01)
            XCTAssertEqual(content.height, frames[index].height, accuracy: 0.01)
        }
    }

    @MainActor
    func testHostingItemMarginsInsetTheContent() throws {
        let probe = SizeProbe()
        let margins = EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
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

        pumpLayout(window, until: { probe.sizes[0] != nil })
        let frame = try XCTUnwrap(cellFrames(in: controller, count: 1).first)
        let content = try XCTUnwrap(probe.sizes[0], "the item never measured its content")
        XCTAssertEqual(content.width, frame.width - 16, accuracy: 0.01)
        XCTAssertEqual(content.height, frame.height - 16, accuracy: 0.01)
    }

    @MainActor
    func testContextMenuPreviewPadsTheCellWhenAsked() throws {
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let controller = SectionsViewController {
            Grid {
                HostingItem(id: "padded") { Color.blue.frame(height: 100) }
                    .contextMenu(menu, previewPadding: 8, previewCornerRadius: 20)
                    .onTap {}
                    .onAppear {}
                    .padding(.zero)
                HostingItem(id: "default") { Color.blue.frame(height: 100) }
                    .contextMenu(menu)
                    .onTap {}
            }
            .spacing(12)
        }
        let window = host(controller)
        defer { window.isHidden = true }

        let collectionView = try XCTUnwrap(controller.collectionView)
        let padded = IndexPath(item: 0, section: 0)
        let paddedCell = try XCTUnwrap(collectionView.cellForItem(at: padded))
        let configuration = try XCTUnwrap(controller.collectionView(
            collectionView,
            contextMenuConfigurationForItemsAt: [padded],
            point: .zero))

        let highlight = controller.collectionView(
            collectionView,
            contextMenuConfiguration: configuration,
            highlightPreviewForItemAt: padded)
        let dismissal = controller.collectionView(
            collectionView,
            contextMenuConfiguration: configuration,
            dismissalPreviewForItemAt: padded)
        for preview in [highlight, dismissal] {
            XCTAssertIdentical(preview?.view, paddedCell)
            XCTAssertEqual(preview?.parameters.visiblePath?.bounds, paddedCell.bounds.insetBy(dx: -8, dy: -8))
        }

        let unpadded = IndexPath(item: 1, section: 0)
        XCTAssertNil(controller.collectionView(
            collectionView,
            contextMenuConfiguration: configuration,
            highlightPreviewForItemAt: unpadded), "nil keeps UIKit's default preview")
        XCTAssertNil(controller.collectionView(
            collectionView,
            contextMenuConfiguration: configuration,
            dismissalPreviewForItemAt: unpadded), "nil keeps UIKit's default preview")
    }
}
#endif
