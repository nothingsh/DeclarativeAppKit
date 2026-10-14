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

    func testLayerModifiers() {
        let view: NSTextField = NSTextField()
            .cornerRadius(12, curve: .continuous)
            .border(color: .systemRed, width: 2)
            .shadow(opacity: 0.3, radius: 6, offset: CGSize(width: 1, height: 2))

        XCTAssertTrue(view.wantsLayer)
        XCTAssertEqual(view.layer?.cornerRadius, 12)
        XCTAssertEqual(view.layer?.cornerCurve, .continuous)
        XCTAssertEqual(view.layer?.borderColor, NSColor.systemRed.cgColor)
        XCTAssertEqual(view.layer?.borderWidth, 2)
        XCTAssertEqual(view.shadow?.shadowColor, NSColor.shadowColor.withAlphaComponent(0.3))
        XCTAssertEqual(view.shadow?.shadowBlurRadius, 6)
    }

    func testShadowOffsetPointsTowardTheBottom() {
        let host = LayoutTestHost(size: CGSize(width: 100, height: 100))
        let view = SizedView(width: 40, height: 40)
            .configure {
                $0.wantsLayer = true
                $0.layer?.backgroundColor = NSColor.white.cgColor
            }
            .shadow(color: .black, opacity: 1, radius: 0, offset: CGSize(width: 0, height: 10))
        host.place(view)
        view.displayIfNeeded()

        // Render the view's layer, with its shadow, 30 points in from every edge.
        let context = CGContext(
            data: nil, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.translateBy(x: 30, y: 30)
        view.layer?.render(in: context)
        let image = NSBitmapImageRep(cgImage: context.makeImage()!)

        // Rows count from the top; the view covers rows 30 to 69.
        XCTAssertEqual(image.colorAt(x: 50, y: 75)?.alphaComponent, 1, "The shadow shows below the view.")
        XCTAssertEqual(image.colorAt(x: 50, y: 25)?.alphaComponent, 0, "The shadow does not show above it.")
    }
}
