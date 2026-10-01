import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class MountingTests: XCTestCase {

    private let safeArea = NSEdgeInsets(top: 11, left: 13, bottom: 17, right: 19)

    /// Active constraints that tie `content` to `parent` by an edge.
    private func edgeConstraints(_ content: NSView, _ parent: NSView) -> [NSLayoutConstraint] {
        let edges: Set<NSLayoutConstraint.Attribute> = [.leading, .trailing, .top, .bottom]
        return parent.constraints.filter { constraint in
            constraint.isActive
                && edges.contains(constraint.firstAttribute)
                && ((constraint.firstItem as? NSView) === content
                    || (constraint.secondItem as? NSView) === content)
        }
    }

    func testMountFillsParentIgnoringSafeArea() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640), additionalSafeAreaInsets: safeArea)
        let content = SizedView(width: 10, height: 10)

        let returned: SizedView = host.rootView.addContent(content)
        host.layout()

        XCTAssertTrue(returned === content)
        XCTAssertNotEqual(
            host.rootView.safeAreaLayoutGuide.frame,
            host.rootView.bounds,
            "The host must have a real safe area for this assertion to mean anything."
        )
        XCTAssertEqual(content.frame, host.rootView.bounds)
        XCTAssertFalse(content.hasAmbiguousLayout)

        host.resize(to: CGSize(width: 640, height: 320))
        XCTAssertEqual(content.frame, host.rootView.bounds)
    }

    func testSafeAreaEdgesFollowSafeAreaGuide() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640), additionalSafeAreaInsets: safeArea)
        let content = NSView()

        host.rootView.addContent(content, safeArea: [.top, .leading])
        host.layout()

        // The root view is not flipped, so its top edge is maxY.
        let safe = host.rootView.safeAreaLayoutGuide.frame
        let bounds = host.rootView.bounds
        XCTAssertNotEqual(safe, bounds)
        XCTAssertEqual(content.frame.maxY, safe.maxY)
        XCTAssertEqual(content.frame.minX, safe.minX)
        XCTAssertEqual(content.frame.minY, bounds.minY)
        XCTAssertEqual(content.frame.maxX, bounds.maxX)
    }

    func testRemountReplacesTheOldConstraints() {
        let first = NSView(), second = NSView(), content = NSView()

        first.addContent(content)
        first.addContent(content)
        XCTAssertEqual(edgeConstraints(content, first).count, 4)

        second.addContent(content)
        XCTAssertTrue(content.superview === second)
        XCTAssertEqual(edgeConstraints(content, first).count, 0)
        XCTAssertEqual(edgeConstraints(content, second).count, 4)
    }
}
