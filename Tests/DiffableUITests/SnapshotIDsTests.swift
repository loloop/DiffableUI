#if canImport(UIKit)
import UIKit
import XCTest
@testable import DiffableUI

final class SnapshotIDsTests: XCTestCase {
    func testIdsKeepTheirNumbersAcrossReloads() {
        var ids = SnapshotIDs()
        let first = ids.snapshot(of: [List { Label("a"); Label("b") }])
        let second = ids.snapshot(of: [List { Label("b"); Label("c"); Label("a") }])

        XCTAssertEqual(second.sectionIdentifiers, first.sectionIdentifiers)
        XCTAssertEqual(second.itemIdentifiers[0], first.itemIdentifiers[1], "b keeps its number")
        XCTAssertEqual(second.itemIdentifiers[2], first.itemIdentifiers[0], "a keeps its number")
        XCTAssertFalse(first.itemIdentifiers.contains(second.itemIdentifiers[1]), "c gets a new number")
    }

    func testItemsOfDifferentTypesNeverShareANumber() {
        var ids = SnapshotIDs()
        let label = ids.snapshot(of: [List { Label("a") }])
        let toggle = ids.snapshot(of: [List { Toggle(id: "a", state: false) }])

        XCTAssertNotEqual(toggle.itemIdentifiers, label.itemIdentifiers, "a Toggle needs a new cell, not the Label's")
    }
}
#endif
