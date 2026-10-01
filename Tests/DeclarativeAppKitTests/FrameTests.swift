import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class FrameTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    private func size(_ view: NSView) -> CGSize {
        if view.superview == nil { host.place(view) }
        host.layout()
        return view.frame.size
    }

    /// The constraints this library created on `view`.
    private func libraryConstraints(_ view: NSView) -> [NSLayoutConstraint] {
        view.constraints.filter { $0.identifier?.hasPrefix("DeclarativeAppKit.") == true }
    }

    func testFixedSizeAndRepeatedCalls() {
        let view = NSView().frame(width: 40, height: 30)
        XCTAssertEqual(size(view), CGSize(width: 40, height: 30))

        view.frame(width: 60)
        XCTAssertEqual(size(view), CGSize(width: 60, height: 30), "A nil axis is left as it is.")
        XCTAssertEqual(libraryConstraints(view).count, 2, "A repeated call updates, it does not add.")
    }

    func testRangeClampsTheIntrinsicSize() {
        XCTAssertEqual(
            size(SizedView(width: 10, height: 10).frame(minWidth: 50, minHeight: 20)),
            CGSize(width: 50, height: 20)
        )
        XCTAssertEqual(
            size(SizedView(width: 100, height: 100).frame(maxWidth: 50, maxHeight: 60)),
            CGSize(width: 50, height: 60)
        )

        let unbounded = SizedView(width: 100, height: 10).frame(maxWidth: .infinity)
        XCTAssertEqual(size(unbounded).width, 100)
        XCTAssertTrue(libraryConstraints(unbounded).isEmpty, ".infinity adds no constraint.")
    }

    func testRedefiningAnAxisReplacesItsEarlierConstraints() {
        let view = SizedView(width: 10, height: 10).frame(minWidth: 20, maxWidth: 30)
        XCTAssertEqual(size(view).width, 20)

        view.frame(width: 50)
        XCTAssertEqual(size(view).width, 50, "A fixed width removes the earlier range.")
        XCTAssertEqual(libraryConstraints(view).count, 1)

        view.frame(maxWidth: 5)
        XCTAssertEqual(size(view).width, 5, "A range removes the earlier fixed width.")
        XCTAssertEqual(libraryConstraints(view).count, 1)

        view.frame(minWidth: 40, maxWidth: 60)
        XCTAssertEqual(size(view).width, 40, "A range replaces an earlier range it does not overlap.")
        XCTAssertEqual(libraryConstraints(view).count, 2)
    }

    func testAspectRatio() {
        let view = NSView().frame(width: 40).frame(aspectRatio: 2)
        XCTAssertEqual(size(view), CGSize(width: 40, height: 20))

        view.frame(aspectRatio: 4)
        XCTAssertEqual(size(view), CGSize(width: 40, height: 10), "A repeated call replaces the ratio.")

        view.frame(aspectRatio: nil).frame(height: 7)
        XCTAssertEqual(size(view), CGSize(width: 40, height: 7), "nil removes the ratio.")
    }

    func testLayoutPriorities() {
        let view: SizedView = SizedView(width: 10, height: 10)
            .contentHuggingPriority(.required, for: .horizontal)
            .compressionResistancePriority(.defaultLow, for: .vertical)

        XCTAssertEqual(view.contentHuggingPriority(for: .horizontal), .required)
        XCTAssertEqual(view.contentCompressionResistancePriority(for: .vertical), .defaultLow)
    }
}
