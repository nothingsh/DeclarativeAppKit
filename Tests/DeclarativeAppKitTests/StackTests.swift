import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class StackTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    func testConstructionDefaults() {
        let stack = VStack {
            NSView()
            NSView()
        }

        XCTAssertEqual(stack.orientation, .vertical)
        XCTAssertEqual(stack.alignment, .centerX)
        XCTAssertEqual(stack.spacing, 0)
        XCTAssertEqual(stack.distribution, .fill)
        XCTAssertNil(stack.superview, "Constructing a stack must not mount it anywhere.")
        XCTAssertEqual(stack.arrangedSubviews.count, 2)

        let row = HStack { NSView() }
        XCTAssertEqual(row.orientation, .horizontal)
        XCTAssertEqual(row.alignment, .centerY)
        XCTAssertEqual(row.distribution, .fill)
    }

    func testAlignmentsMapToAppKitValues() {
        XCTAssertEqual(HStack(alignment: .top) {}.alignment, .top)
        XCTAssertEqual(HStack(alignment: .bottom) {}.alignment, .bottom)
        XCTAssertEqual(HStack(alignment: .firstTextBaseline) {}.alignment, .firstBaseline)
        XCTAssertEqual(HStack(alignment: .lastTextBaseline) {}.alignment, .lastBaseline)

        XCTAssertEqual(VStack(alignment: .leading) {}.alignment, .leading)
        XCTAssertEqual(VStack(alignment: .trailing) {}.alignment, .trailing)
    }

    func testModifiersOverrideConstructionValues() {
        let stack: VStack = VStack(alignment: .leading, spacing: 4) {}
            .spacing(12)
            .distribution(.equalSpacing)
            .alignment(.trailing)

        XCTAssertEqual(stack.spacing, 12)
        XCTAssertEqual(stack.distribution, .equalSpacing)
        XCTAssertEqual(stack.alignment, .trailing)
    }

    func testVStackStacksFromTheTopInDeclarationOrder() {
        let first = SizedView(width: 50, height: 20)
        let second = SizedView(width: 80, height: 30)
        let stack = VStack(alignment: .leading) {
            first
            second
        }
        host.place(stack)

        XCTAssertEqual(stack.frame.size, CGSize(width: 80, height: 50))
        XCTAssertEqual(first.frame, CGRect(x: 0, y: 0, width: 50, height: 20))
        XCTAssertEqual(second.frame, CGRect(x: 0, y: 20, width: 80, height: 30))
        XCTAssertFalse(stack.hasAmbiguousLayout)
    }

    func testHStackCentersOnTheCrossAxisAndAppliesSpacing() {
        let first = SizedView(width: 50, height: 20)
        let second = SizedView(width: 80, height: 40)
        let stack = HStack(spacing: 6) {
            first
            second
        }
        host.place(stack)

        XCTAssertEqual(stack.frame.size, CGSize(width: 136, height: 40))
        XCTAssertEqual(first.frame, CGRect(x: 0, y: 10, width: 50, height: 20))
        XCTAssertEqual(second.frame, CGRect(x: 56, y: 0, width: 80, height: 40))
    }

    func testFillStretchesOnTheCrossAxis() {
        // Hugging above the stack's own alignment priority: only the fill constraints stretch it.
        let narrow = SizedView(width: 50, height: 20).contentHuggingPriority(.init(500), for: .horizontal)
        let wide = SizedView(width: 80, height: 20)
        let column = VStack(alignment: .fill) {
            narrow
            wide
        }
        host.place(column)

        XCTAssertEqual(column.frame.size, CGSize(width: 80, height: 40), "Fill does not enlarge the stack.")
        XCTAssertEqual(narrow.frame, CGRect(x: 0, y: 0, width: 80, height: 20))
        XCTAssertFalse(column.hasAmbiguousLayout)

        let short = SizedView(width: 50, height: 20)
        let tall = SizedView(width: 50, height: 40)
        let row = HStack(alignment: .fill) {
            short
            tall
        }
        host.place(row)

        XCTAssertEqual(short.frame, CGRect(x: 0, y: 0, width: 50, height: 40))
    }

    func testAlignmentModifierSwitchesToAndFromFill() {
        let narrow = SizedView(width: 50, height: 20)
        let column = VStack(alignment: .leading) {
            narrow
            SizedView(width: 80, height: 20)
        }
        host.place(column)
        XCTAssertEqual(narrow.frame.width, 50)

        column.alignment(.fill)
        host.layout()
        XCTAssertEqual(narrow.frame.width, 80)

        column.alignment(.trailing)
        host.layout()
        XCTAssertEqual(narrow.frame, CGRect(x: 30, y: 0, width: 50, height: 20))
    }

    func testAlignmentSetThroughTheAppKitPropertyIsFollowed() {
        let centered = SizedView(width: 50, height: 20)
        let column = VStack { centered }
            .padding(top: 0, leading: 10, bottom: 0, trailing: 30)
            .frame(width: 200)
        host.place(column)
        XCTAssertEqual(centered.frame, CGRect(x: 65, y: 0, width: 50, height: 20))

        column.alignment = .leading
        host.layout()
        XCTAssertEqual(centered.frame, CGRect(x: 10, y: 0, width: 50, height: 20), "No longer centered.")

        column.alignment = .centerX
        host.layout()
        XCTAssertEqual(centered.frame, CGRect(x: 65, y: 0, width: 50, height: 20), "Centered between the padded edges.")

        let filled = SizedView(width: 20, height: 50)
        let row = HStack(alignment: .fill) { filled }.frame(height: 200)
        host.place(row)
        XCTAssertEqual(filled.frame.height, 200)

        row.alignment = .bottom
        host.layout()
        XCTAssertEqual(filled.frame, CGRect(x: 0, y: 150, width: 20, height: 50), "No longer filled.")

        row.alignment(.fill)
        host.layout()
        XCTAssertEqual(filled.frame.height, 200)

        // `top` and `fill` share one AppKit alignment, so only the modifier tells them apart.
        row.alignment(.top)
        host.layout()
        XCTAssertEqual(filled.frame, CGRect(x: 0, y: 0, width: 20, height: 50))
    }

    func testFillCoversAnElementAddedAfterConstruction() {
        let column = VStack(alignment: .fill) {
            SizedView(width: 80, height: 20)
        }
        host.place(column)

        let late = SizedView(width: 50, height: 20)
        column.addArrangedSubview(late)
        host.layout()

        XCTAssertEqual(late.frame, CGRect(x: 0, y: 20, width: 80, height: 20))
    }

    func testHiddenElementDoesNotSizeTheStack() {
        let wide = SizedView(width: 190, height: 20)
        let column = VStack(alignment: .leading) {
            wide
            SizedView(width: 50, height: 20)
        }
        host.place(column)
        XCTAssertEqual(column.frame.size, CGSize(width: 190, height: 40))

        wide.isHidden = true
        host.layout()
        XCTAssertEqual(column.frame.size, CGSize(width: 50, height: 20))

        wide.isHidden = false
        host.layout()
        XCTAssertEqual(column.frame.size, CGSize(width: 190, height: 40))
    }

    func testAddStackMethodsMountOnTheParentsEdges() {
        let first = SizedView(width: 50, height: 20)
        let column: VStack = host.rootView.addVStack(alignment: .leading, spacing: 0) {
            first
        }
        host.layout()

        XCTAssertTrue(column.superview === host.rootView)
        XCTAssertEqual(column.frame, host.rootView.bounds)
        XCTAssertEqual(first.frame.origin, .zero)

        let other = LayoutTestHost(size: CGSize(width: 400, height: 400))
        let row: HStack = other.rootView.addHStack {
            SizedView(width: 50, height: 20)
        }
        other.layout()
        XCTAssertEqual(row.frame, other.rootView.bounds)
    }

    func testLeadingAlignmentMirrorsInRightToLeft() {
        let first = SizedView(width: 50, height: 20)
        let column = VStack(alignment: .leading) { first }.frame(width: 200)
        column.userInterfaceLayoutDirection = .rightToLeft
        host.place(column)

        XCTAssertEqual(first.frame.maxX, 200, "Leading is the right edge in a right-to-left layout.")
        XCTAssertEqual(first.frame.width, 50)
    }
}
