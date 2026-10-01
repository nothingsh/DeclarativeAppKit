import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class DecorationTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    /// A 70 x 40 stack: one 50 x 20 element with 10 of padding.
    private func stack() -> VStack {
        VStack {
            SizedView(width: 50, height: 20)
        }.padding(10)
    }

    func testBackgroundSitsBehindTheContentAndCoversThePadding() {
        let first = NSView(), second = NSView()
        let column = stack()
            .background { first }
            .background { second }
        host.place(column)

        XCTAssertEqual(column.frame.size, CGSize(width: 70, height: 40))
        XCTAssertEqual(first.frame, column.bounds)
        XCTAssertEqual(column.arrangedSubviews.count, 1, "A decoration is not an arranged subview.")
        XCTAssertTrue(column.subviews[0] === second, "A later background goes further back.")
        XCTAssertTrue(column.subviews[1] === first)
        XCTAssertFalse(column.hasAmbiguousLayout)
    }

    func testFillDecorationDoesNotEnlargeTheStack() {
        let large = SizedView(width: 300, height: 300)
        let column = stack().background { large }
        host.place(column)

        XCTAssertEqual(column.frame.size, CGSize(width: 70, height: 40))
        XCTAssertEqual(large.frame, column.bounds)
    }

    func testOverlayAlignments() {
        func badgeFrame(_ alignment: LayoutAlignment) -> CGRect {
            let badge = SizedView(width: 10, height: 10)
            let column = stack().overlay(alignment: alignment) { badge }
            host.place(column)
            XCTAssertTrue(column.subviews.last === badge, "An overlay goes in front.")
            return badge.frame
        }

        XCTAssertEqual(badgeFrame(.topLeading), CGRect(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.top), CGRect(x: 30, y: 0, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.topTrailing), CGRect(x: 60, y: 0, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.leading), CGRect(x: 0, y: 15, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.center), CGRect(x: 30, y: 15, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.trailing), CGRect(x: 60, y: 15, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottomLeading), CGRect(x: 0, y: 30, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottom), CGRect(x: 30, y: 30, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottomTrailing), CGRect(x: 60, y: 30, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.fill), CGRect(x: 0, y: 0, width: 70, height: 40))
    }

    func testOffsetMovesADecorationFromItsAlignment() {
        func badgeFrame(_ alignment: LayoutAlignment, _ offset: CGPoint) -> CGRect {
            let badge = SizedView(width: 10, height: 10)
            let column = stack().overlay(alignment: alignment, offset: offset) { badge }
            host.place(column)
            XCTAssertEqual(column.frame.size, CGSize(width: 70, height: 40), "An offset never resizes the view.")
            return badge.frame
        }

        // x is positive toward the right and y toward the bottom, from where the alignment puts it.
        XCTAssertEqual(badgeFrame(.topTrailing, CGPoint(x: 4, y: -3)), CGRect(x: 64, y: -3, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.center, CGPoint(x: 5, y: 6)), CGRect(x: 35, y: 21, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottomLeading, CGPoint(x: -2, y: 2)), CGRect(x: -2, y: 32, width: 10, height: 10))

        let behind = SizedView(width: 10, height: 10)
        let column = stack().background(alignment: .bottom, offset: CGPoint(x: 0, y: 4)) { behind }
        host.place(column)
        XCTAssertEqual(behind.frame, CGRect(x: 30, y: 34, width: 10, height: 10))
        XCTAssertTrue(column.subviews.first === behind)
    }

    func testOverlayOnAPlainView() {
        let badge = SizedView(width: 10, height: 10)
        let view = NSView().frame(width: 100, height: 50).overlay(alignment: .bottomTrailing) { badge }
        host.place(view)

        // A plain view is not flipped, so its bottom edge is minY.
        XCTAssertEqual(badge.frame, CGRect(x: 90, y: 0, width: 10, height: 10))
    }

    func testColorBackgroundAddsAFillViewBehindTheContent() throws {
        let column = stack().background(.systemRed)
        host.place(column)

        let fill = try XCTUnwrap(column.subviews.first as? NSBox)
        XCTAssertEqual(fill.boxType, .custom)
        XCTAssertEqual(fill.borderWidth, 0)
        XCTAssertEqual(fill.fillColor, .systemRed)
        XCTAssertEqual(fill.frame, column.bounds)
        XCTAssertEqual(column.frame.size, CGSize(width: 70, height: 40))
        XCTAssertEqual(column.arrangedSubviews.count, 1)
    }
}
