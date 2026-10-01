import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class ViewPropertyTests: XCTestCase {

    func testViewModifiersSetTheirPropertyAndKeepTheConcreteType() {
        var configured: NSTextField?
        let field: NSTextField = NSTextField()
            .alphaValue(0.5)
            .isHidden(true)
            .toolTip("Hint")
            .clipsToBounds(true)
            .accessibilityLabel("Name")
            .accessibilityIdentifier("name-field")
            .configure { configured = $0 }

        XCTAssertEqual(field.alphaValue, 0.5)
        XCTAssertTrue(field.isHidden)
        XCTAssertEqual(field.toolTip, "Hint")
        XCTAssertTrue(field.clipsToBounds)
        XCTAssertEqual(field.accessibilityLabel(), "Name")
        XCTAssertEqual(field.accessibilityIdentifier(), "name-field")
        XCTAssertTrue(configured === field)
    }
}
