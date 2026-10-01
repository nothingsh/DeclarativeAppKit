import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class ScrollTests: XCTestCase {

    private let host = LayoutTestHost(size: CGSize(width: 400, height: 400))

    private func scroll(_ scrollView: NSScrollView, to point: NSPoint) {
        scrollView.contentView.scroll(to: point)
        scrollView.reflectScrolledClipView(scrollView.contentView)
        host.layout()
    }

    func testConstructionDefaultsAndIndicators() {
        let vertical = VScroll {}
        XCTAssertTrue(vertical.documentView === vertical.stack)
        XCTAssertTrue(vertical.hasVerticalScroller)
        XCTAssertFalse(vertical.hasHorizontalScroller)
        XCTAssertFalse(vertical.drawsBackground)
        XCTAssertFalse(vertical.automaticallyAdjustsContentInsets)
        XCTAssertNil(vertical.superview, "Constructing a scroll view must not mount it anywhere.")
        XCTAssertFalse(VScroll(showsIndicators: false) {}.hasVerticalScroller)
        XCTAssertFalse(vertical.showsIndicators(false).hasVerticalScroller)

        let horizontal = HScroll {}
        XCTAssertTrue(horizontal.documentView === horizontal.stack)
        XCTAssertTrue(horizontal.hasHorizontalScroller)
        XCTAssertFalse(horizontal.hasVerticalScroller)
        XCTAssertFalse(HScroll(showsIndicators: false) {}.hasHorizontalScroller)
        XCTAssertFalse(horizontal.showsIndicators(false).hasHorizontalScroller)
    }

    func testModifiersReachTheEmbeddedStack() {
        let vertical: VScroll = VScroll {}.alignment(.trailing).spacing(8).padding(12).padding(.top, 4)
        XCTAssertEqual(vertical.stack.alignment, .trailing)
        XCTAssertEqual(vertical.stack.spacing, 8)
        XCTAssertTrue(NSEdgeInsetsEqual(
            vertical.stack.edgeInsets,
            NSEdgeInsets(top: 4, left: 12, bottom: 12, right: 12)
        ))

        let horizontal: HScroll = HScroll {}.alignment(.bottom).spacing(6).padding(3)
        XCTAssertEqual(horizontal.stack.alignment, .bottom)
        XCTAssertEqual(horizontal.stack.spacing, 6)
        XCTAssertTrue(NSEdgeInsetsEqual(
            horizontal.stack.edgeInsets,
            NSEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        ))
    }

    func testVScrollStartsAtTheTopAndScrollsItsContent() {
        let rows = (0..<10).map { _ in SizedView(width: 50, height: 100) }
        let scrollView: VScroll = host.rootView.addVScroll(alignment: .leading) { rows }
        host.layout()

        let visibleWidth = scrollView.contentView.bounds.width
        XCTAssertEqual(scrollView.frame, host.rootView.bounds)
        XCTAssertEqual(scrollView.stack.frame, CGRect(x: 0, y: 0, width: visibleWidth, height: 1000))
        XCTAssertEqual(scrollView.documentVisibleRect.origin, .zero, "The first row is at the top.")
        XCTAssertEqual(rows[0].frame.minY, 0)

        scroll(scrollView, to: NSPoint(x: 0, y: 500))
        XCTAssertEqual(scrollView.documentVisibleRect.origin, CGPoint(x: 0, y: 500))
        XCTAssertEqual(scrollView.stack.frame.origin, .zero, "Scrolling moves the visible area, not the content.")
        XCTAssertEqual(rows[5].convert(rows[5].bounds, to: host.rootView).maxY, 400, "Row 5 is now at the top.")
    }

    func testHScrollScrollsItsContentAndFollowsTheHeight() {
        let columns = (0..<10).map { _ in SizedView(width: 100, height: 50) }
        let scrollView: HScroll = host.rootView.addHScroll { columns }
        host.layout()

        let visibleHeight = scrollView.contentView.bounds.height
        XCTAssertEqual(scrollView.stack.frame, CGRect(x: 0, y: 0, width: 1000, height: visibleHeight))
        XCTAssertEqual(scrollView.documentVisibleRect.origin, .zero)

        scroll(scrollView, to: NSPoint(x: 400, y: 0))
        XCTAssertEqual(scrollView.documentVisibleRect.origin, CGPoint(x: 400, y: 0))
    }

    func testContentShorterThanTheScrollViewStaysAtTheTop() {
        let row = SizedView(width: 50, height: 100)
        host.rootView.addVScroll(alignment: .leading) { row }
        host.layout()

        // The root view is not flipped, so its top edge is maxY.
        XCTAssertEqual(row.convert(row.bounds, to: host.rootView).maxY, 400)
    }

    func testContentFollowsTheScrollViewWhenItIsResized() {
        let scrollView: VScroll = host.rootView.addVScroll(alignment: .fill) {
            SizedView(width: 50, height: 100)
        }
        host.layout()
        XCTAssertEqual(scrollView.stack.frame.width, scrollView.contentView.bounds.width)

        host.resize(to: CGSize(width: 300, height: 400))
        XCTAssertEqual(scrollView.frame.width, 300)
        XCTAssertEqual(scrollView.stack.frame.width, scrollView.contentView.bounds.width)
    }

    func testSpacerIsOnlyItsMinimumLengthAlongTheScrollingAxis() {
        let spacer = Spacer(minLength: 20)
        let scrollView: VScroll = host.rootView.addVScroll {
            SizedView(width: 50, height: 100)
            spacer
            SizedView(width: 50, height: 100)
        }
        host.layout()

        XCTAssertEqual(spacer.frame.height, 20)
        XCTAssertEqual(scrollView.stack.frame.height, 220)
    }

    func testScrollViewModifiers() {
        let scrollView: NSScrollView = NSScrollView()
            .horizontalScrollElasticity(.none)
            .verticalScrollElasticity(.allowed)
            .scrollerStyle(.legacy)
            .autohidesScrollers(true)
            .drawsBackground(true)
            .backgroundColor(.systemBlue)

        XCTAssertEqual(scrollView.horizontalScrollElasticity, .none)
        XCTAssertEqual(scrollView.verticalScrollElasticity, .allowed)
        XCTAssertEqual(scrollView.scrollerStyle, .legacy)
        XCTAssertTrue(scrollView.autohidesScrollers)
        XCTAssertTrue(scrollView.drawsBackground)
        XCTAssertEqual(scrollView.backgroundColor, .systemBlue)
    }
}
