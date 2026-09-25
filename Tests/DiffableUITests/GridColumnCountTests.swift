#if canImport(UIKit)
import UIKit
import XCTest
@testable import DiffableUI

@available(iOS 16.0, *)
final class GridColumnCountTests: XCTestCase {
    func testAdaptiveColumnsFitTheMinimumItemWidth() {
        let grid = Grid { Empty() }.minimumItemWidth(160)
        XCTAssertEqual(grid.columnCount(fitting: 440), 2)
        XCTAssertEqual(grid.columnCount(fitting: 479), 2)
        XCTAssertEqual(grid.columnCount(fitting: 480), 3)
        XCTAssertEqual(grid.columnCount(fitting: 100), 1, "narrower than one item still gets a column")
    }

    func testSpacingCountsTowardsTheWidth() {
        let grid = Grid { Empty() }.minimumItemWidth(160).spacing(12)
        // Three columns need 3 * 160 + 2 * 12 = 504pt.
        XCTAssertEqual(grid.columnCount(fitting: 480), 2)
        XCTAssertEqual(grid.columnCount(fitting: 503), 2)
        XCTAssertEqual(grid.columnCount(fitting: 504), 3)
        // Two columns need 2 * 160 + 12 = 332pt.
        XCTAssertEqual(grid.columnCount(fitting: 331), 1)
        XCTAssertEqual(grid.columnCount(fitting: 332), 2)
    }

    func testInsetsNarrowTheWidth() {
        let grid = Grid { Empty() }
            .minimumItemWidth(144)
            .spacing(12)
            .insets(.horizontal(16))
        XCTAssertEqual(grid.columnCount(fitting: 402), 2)
        XCTAssertEqual(grid.columnCount(fitting: 1032), 6)
        XCTAssertEqual(grid.columnCount(fitting: 1376), 8)
    }

    func testMinimumColumnsIsAFloor() {
        let grid = Grid { Empty() }
            .minimumItemWidth(114)
            .spacing(8)
            .insets(.horizontal(16))
            .minimumColumns(3)
        XCTAssertEqual(grid.columnCount(fitting: 390), 3)
        XCTAssertEqual(grid.columnCount(fitting: 320), 3, "shrinks items below the minimum width")
        XCTAssertEqual(grid.columnCount(fitting: 0), 3)
        XCTAssertEqual(grid.columnCount(fitting: 1032), 8, "wider containers still add columns")
    }

    func testFixedColumnsOverrideTheAdaptiveCount() {
        let grid = Grid { Empty() }
            .minimumItemWidth(160)
            .minimumColumns(6)
            .columns(4)
        XCTAssertEqual(grid.columnCount(fitting: 100), 4)
        XCTAssertEqual(grid.columnCount(fitting: 2000), 4)
        XCTAssertEqual(grid.columns(nil).columnCount(fitting: 2000), 12, "nil goes back to adaptive")
        XCTAssertEqual(grid.columns(0).columnCount(fitting: 440), 1)
    }

    func testZeroWidthStillLaysOutOneColumn() {
        XCTAssertEqual(Grid { Empty() }.columnCount(fitting: 0), 1)
        XCTAssertEqual(Grid { Empty() }.spacing(12).insets(.horizontal(16)).columnCount(fitting: 0), 1)
        XCTAssertEqual(Grid { Empty() }.minimumItemWidth(0).columnCount(fitting: 440), 1)
    }
}
#endif
