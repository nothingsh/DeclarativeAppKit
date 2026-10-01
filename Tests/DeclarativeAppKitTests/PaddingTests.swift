import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class PaddingTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    private func stack() -> VStack {
        VStack(alignment: .fill) {
            SizedView(width: 20, height: 30)
        }
    }

    private func assertInsets(
        _ stack: NSStackView,
        top: CGFloat,
        leading: CGFloat,
        bottom: CGFloat,
        trailing: CGFloat,
        line: UInt = #line
    ) {
        let expected = NSEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        XCTAssertTrue(
            NSEdgeInsetsEqual(stack.edgeInsets, expected),
            "\(stack.edgeInsets) is not \(expected)",
            line: line
        )
    }

    func testPaddingIsAddedToFittingSize() {
        XCTAssertEqual(stack().padding(10).alignment(.leading).fittingSize, CGSize(width: 40, height: 50))
        XCTAssertEqual(
            stack().padding(4).padding(6).fittingSize,
            CGSize(width: 32, height: 42),
            "Padding is a property: the last call wins."
        )
        XCTAssertEqual(
            stack().padding(.horizontal, 5).fittingSize,
            CGSize(width: 30, height: 30),
            "Edges not named stay at 0."
        )
        XCTAssertEqual(
            stack().padding(.horizontal, 16).padding(.vertical, 12).fittingSize,
            CGSize(width: 52, height: 54),
            "A later call keeps the edges it does not name."
        )
        XCTAssertEqual(stack().padding().fittingSize, CGSize(width: 52, height: 62))
    }

    func testSingleCallPaddingSetsEveryEdge() {
        assertInsets(stack().padding(1).padding(horizontal: 12, vertical: 4), top: 4, leading: 12, bottom: 4, trailing: 12)
        assertInsets(
            stack().padding(1).padding(top: 2, leading: 3, bottom: 4, trailing: 5),
            top: 2, leading: 3, bottom: 4, trailing: 5
        )
        assertInsets(stack().padding(1).padding(.top, 24, others: 8), top: 24, leading: 8, bottom: 8, trailing: 8)
        assertInsets(
            stack().padding([.leading, .bottom], 20, others: 6),
            top: 6, leading: 20, bottom: 20, trailing: 6
        )
        assertInsets(
            stack().padding(NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)),
            top: 1, leading: 2, bottom: 3, trailing: 4
        )
    }

    func testCrossAxisPaddingIsKeptWhenAnElementIsTooWide() {
        let wide = SizedView(width: 190, height: 20)
        let column = VStack(alignment: .leading) { wide }
            .padding(top: 0, leading: 10, bottom: 0, trailing: 30)
            .frame(width: 200)
        host.place(column)

        XCTAssertEqual(wide.frame, CGRect(x: 10, y: 0, width: 160, height: 20))

        let tall = SizedView(width: 20, height: 190)
        let row = HStack(alignment: .top) { tall }
            .padding(top: 10, leading: 0, bottom: 30, trailing: 0)
            .frame(height: 200)
        host.place(row)

        XCTAssertEqual(tall.frame, CGRect(x: 0, y: 10, width: 20, height: 160))
    }

    func testCenterAlignmentCentersBetweenThePaddedEdges() {
        let element = SizedView(width: 40, height: 20)
        let column = VStack { element }
            .padding(top: 0, leading: 10, bottom: 0, trailing: 30)
            .frame(width: 200)
        host.place(column)

        XCTAssertEqual(element.frame, CGRect(x: 70, y: 0, width: 40, height: 20))
    }

    func testPaddingChangedAfterLayoutMovesTheContent() {
        let content = SizedView(width: 20, height: 30)
        let column = VStack(alignment: .fill) { content }.frame(width: 200)
        host.place(column)
        XCTAssertEqual(content.frame, CGRect(x: 0, y: 0, width: 200, height: 30))

        column.padding(20)
        host.layout()
        XCTAssertEqual(content.frame, CGRect(x: 20, y: 20, width: 160, height: 30))
    }

    func testDirectionalPaddingMirrorsInRightToLeft() {
        func contentFrame(_ direction: NSUserInterfaceLayoutDirection) -> CGRect {
            let content = SizedView(width: 20, height: 30)
            let column = VStack(alignment: .fill) { content }
                .padding(top: 1, leading: 10, bottom: 2, trailing: 30)
                .frame(width: 200)
            column.userInterfaceLayoutDirection = direction
            host.place(column)
            return content.frame
        }

        XCTAssertEqual(contentFrame(.leftToRight), CGRect(x: 10, y: 1, width: 160, height: 30))
        XCTAssertEqual(contentFrame(.rightToLeft), CGRect(x: 30, y: 1, width: 160, height: 30))
    }

    func testPaddingIgnoresTheSafeArea() {
        let safeHost = LayoutTestHost(
            size: CGSize(width: 400, height: 400),
            additionalSafeAreaInsets: NSEdgeInsets(top: 40, left: 4, bottom: 30, right: 8)
        )
        let content = SizedView(width: 20, height: 30)
        let column = safeHost.rootView.addContent(VStack(alignment: .fill) { content }.padding(10))
        safeHost.layout()

        XCTAssertNotEqual(safeHost.rootView.safeAreaLayoutGuide.frame, safeHost.rootView.bounds)
        XCTAssertEqual(content.frame, column.bounds.insetBy(dx: 10, dy: 10))
    }
}
