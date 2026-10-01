import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class SpacerTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    func testSpacerTakesTheRemainingLength() {
        let first = SizedView(width: 50, height: 20)
        let spacer = Spacer()
        // Hugging below the default: the spacer must still be the one that grows.
        let last = SizedView(width: 50, height: 20).contentHuggingPriority(.init(100), for: .horizontal)
        let row = HStack {
            first
            spacer
            last
        }.frame(width: 300)
        host.place(row)

        XCTAssertEqual(spacer.frame.width, 200)
        XCTAssertEqual(spacer.frame.height, 0, "A spacer never grows on the cross axis.")
        XCTAssertEqual(first.frame.width, 50)
        XCTAssertEqual(last.frame.minX, 250)
        XCTAssertEqual(row.frame.height, 20)
        XCTAssertFalse(row.hasAmbiguousLayout)

        let vertical = Spacer()
        let column = VStack {
            SizedView(width: 50, height: 20)
            vertical
            SizedView(width: 50, height: 20)
        }.frame(height: 200)
        host.place(column)

        XCTAssertEqual(vertical.frame.height, 160)
        XCTAssertEqual(column.frame.width, 50)
    }

    func testSpacersShareTheRemainingLengthEqually() {
        let left = Spacer(), right = Spacer()
        let middle = SizedView(width: 50, height: 20)
        let row = HStack {
            SizedView(width: 50, height: 20)
            left
            middle
            right
            SizedView(width: 50, height: 20)
        }.frame(width: 300)
        host.place(row)

        XCTAssertEqual(left.frame.width, 75)
        XCTAssertEqual(right.frame.width, 75)
        XCTAssertEqual(middle.frame.width, 50, "Sharing the space must not stretch a view with content.")
        XCTAssertFalse(row.hasAmbiguousLayout)
    }

    func testRemainingSpacersStillShareEquallyAfterOneIsRemoved() {
        let first = Spacer(), second = Spacer(), third = Spacer()
        let row = HStack {
            first
            SizedView(width: 50, height: 20)
            second
            SizedView(width: 50, height: 20)
            third
        }.frame(width: 400)
        host.place(row)
        XCTAssertEqual([first, second, third].map(\.frame.width), [100, 100, 100])

        first.removeFromSuperview()
        host.layout()
        XCTAssertEqual([second, third].map(\.frame.width), [150, 150])
        XCTAssertFalse(row.hasAmbiguousLayout)
    }

    func testMinLengthIsKeptWhenThereIsNoRemainingLength() {
        let spacer = Spacer(minLength: 24)
        let row = HStack {
            SizedView(width: 50, height: 20)
            spacer
            SizedView(width: 50, height: 20)
        }
        host.place(row)

        XCTAssertEqual(spacer.minLength, 24)
        XCTAssertEqual(spacer.frame.width, 24)
        XCTAssertEqual(row.frame.width, 124)
    }
}
