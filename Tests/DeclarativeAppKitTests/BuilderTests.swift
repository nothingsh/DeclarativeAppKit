import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class BuilderTests: XCTestCase {

    private func build(@NSViewBuilder _ content: () -> [NSView]) -> [NSView] {
        content()
    }

    func testCollectsViewsOptionalsAndArraysInDeclarationOrder() {
        let a = NSView(), b = NSView(), c = NSView(), d = NSView()
        let missing: NSView? = nil
        let present: NSView? = d

        let views = build {
            a
            missing
            [b, c]
            present
        }

        XCTAssertEqual(views, [a, b, c, d])
        XCTAssertTrue(build {}.isEmpty)
    }

    func testControlFlow() {
        let a = NSView(), b = NSView(), c = NSView()
        let repeated = [NSView(), NSView()]

        func views(_ flag: Bool) -> [NSView] {
            build {
                if flag { a } else { b }
                if flag { c }
                for view in repeated { view }
            }
        }

        XCTAssertEqual(views(true), [a, c] + repeated)
        XCTAssertEqual(views(false), [b] + repeated)
    }
}
