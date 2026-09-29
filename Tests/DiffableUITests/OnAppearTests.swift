#if canImport(UIKit)
import UIKit
import XCTest
@testable import DiffableUI

final class OnAppearTests: XCTestCase {
    @MainActor
    func testNonThrowingActionRuns() {
        let appeared = expectation(description: "onAppear runs")
        let item = Label("Plain").onAppear { appeared.fulfill() }

        item.willDisplay()

        wait(for: [appeared], timeout: 1)
    }

    @MainActor
    func testThrownErrorReachesTheHandler() {
        let handled = expectation(description: "onError gets the error")
        let item = Label("Failing")
            .onAppear { throw TestError.failed } onError: { error in
                XCTAssertEqual(error as? TestError, .failed)
                handled.fulfill()
            }

        item.willDisplay()

        wait(for: [handled], timeout: 1)
    }

    @MainActor
    func testHandlerIsNotCalledWhenTheActionSucceeds() {
        let appeared = expectation(description: "onAppear runs")
        let handled = expectation(description: "onError isn't called")
        handled.isInverted = true
        let item = Label("Succeeding")
            .onAppear { appeared.fulfill() } onError: { _ in handled.fulfill() }

        item.willDisplay()

        wait(for: [appeared, handled], timeout: 0.5)
    }

    @MainActor
    func testThrownErrorReachesTheHandlerThroughEveryWrapper() {
        let menu = UIMenu(children: [UIAction(title: "Action") { _ in }])
        let handled = expectation(description: "onError gets the error")
        let item = Label("Wrapped")
            .onAppear { throw TestError.failed } onError: { error in
                XCTAssertEqual(error as? TestError, .failed)
                handled.fulfill()
            }
            .onTap {}
            .padding(.zero)
            .contextMenu(menu)

        item.willDisplay()

        wait(for: [handled], timeout: 1)
    }

    /// DiffableUI never cancels the task, so a `CancellationError` comes from the
    /// action itself and is handed over like any other error.
    @MainActor
    func testCancellationErrorReachesTheHandler() {
        let handled = expectation(description: "onError gets the CancellationError")
        let item = Label("Cancelled")
            .onAppear { throw CancellationError() } onError: { error in
                XCTAssertTrue(error is CancellationError)
                handled.fulfill()
            }

        item.willDisplay()

        wait(for: [handled], timeout: 1)
    }
}

private enum TestError: Error {
    case failed
}
#endif
