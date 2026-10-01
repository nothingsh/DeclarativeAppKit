import AppKit
import XCTest
@testable import DeclarativeAppKit

@MainActor
final class ControlPropertyTests: XCTestCase {

    private let font = NSFont.systemFont(ofSize: 21)

    func testControlModifiers() {
        let field: NSTextField = NSTextField()
            .isEnabled(false)
            .isHighlighted(true)
            .controlSize(.small)
            .font(font)
            .alignment(.right)
            .lineBreakMode(.byTruncatingMiddle)

        XCTAssertFalse(field.isEnabled)
        XCTAssertTrue(field.isHighlighted)
        XCTAssertEqual(field.controlSize, .small)
        XCTAssertEqual(field.font, font)
        XCTAssertEqual(field.alignment, .right)
        XCTAssertEqual(field.lineBreakMode, .byTruncatingMiddle)
    }

    func testTextFieldModifiers() {
        let attributed = NSAttributedString(string: "Styled")
        let field: NSTextField = NSTextField()
            .stringValue("Ada")
            .placeholderString("Name")
            .textColor(.systemRed)
            .maximumNumberOfLines(3)
            .isEditable(false)
            .isSelectable(true)

        XCTAssertEqual(field.stringValue, "Ada")
        XCTAssertEqual(field.placeholderString, "Name")
        XCTAssertEqual(field.textColor, .systemRed)
        XCTAssertEqual(field.maximumNumberOfLines, 3)
        XCTAssertFalse(field.isEditable)
        XCTAssertTrue(field.isSelectable)
        XCTAssertEqual(NSTextField().attributedStringValue(attributed).attributedStringValue.string, "Styled")
    }

    func testButtonModifiers() {
        let image = NSImage(size: NSSize(width: 4, height: 4))
        let alternate = NSImage(size: NSSize(width: 4, height: 4))
        let button: NSButton = NSButton()
            .buttonType(.toggle)
            .bezelStyle(.inline)
            .title("Play")
            .alternateTitle("Pause")
            .image(image)
            .alternateImage(alternate)
            .imagePosition(.imageLeading)
            .contentTintColor(.systemGreen)
            .state(.on)

        // A toggle shows its state; the default momentary button does not.
        let showsState = (button.cell as? NSButtonCell)?.showsStateBy
        XCTAssertNotNil(showsState)
        XCTAssertNotEqual(showsState, (NSButton().cell as? NSButtonCell)?.showsStateBy)
        XCTAssertEqual(button.bezelStyle, .inline)
        XCTAssertEqual(button.title, "Play")
        XCTAssertEqual(button.alternateTitle, "Pause")
        XCTAssertTrue(button.image === image)
        XCTAssertTrue(button.alternateImage === alternate)
        XCTAssertEqual(button.imagePosition, .imageLeading)
        XCTAssertEqual(button.contentTintColor, .systemGreen)
        XCTAssertEqual(button.state, .on)
        XCTAssertEqual(
            NSButton().attributedTitle(NSAttributedString(string: "Styled")).attributedTitle.string,
            "Styled"
        )
    }

    func testTextViewModifiers() {
        let textView: NSTextView = NSTextView()
            .string("Notes")
            .font(font)
            .textColor(.systemRed)
            .alignment(.center)
            .isEditable(false)
            .isSelectable(false)

        XCTAssertEqual(textView.string, "Notes")
        XCTAssertEqual(textView.font, font)
        XCTAssertEqual(textView.textColor, .systemRed)
        XCTAssertEqual(textView.alignment, .center)
        XCTAssertFalse(textView.isEditable)
        XCTAssertFalse(textView.isSelectable)
    }

    func testSliderSwitchAndImageViewModifiers() {
        let slider: NSSlider = NSSlider()
            .minValue(10)
            .maxValue(20)
            .doubleValue(15)
            .trackFillColor(.systemOrange)
        XCTAssertEqual(slider.minValue, 10)
        XCTAssertEqual(slider.maxValue, 20)
        XCTAssertEqual(slider.doubleValue, 15)
        XCTAssertEqual(slider.trackFillColor, .systemOrange)

        let toggle: NSSwitch = NSSwitch().state(.on)
        XCTAssertEqual(toggle.state, .on)

        let image = NSImage(size: NSSize(width: 4, height: 4))
        let imageView: NSImageView = NSImageView()
            .image(image)
            .imageScaling(.scaleProportionallyUpOrDown)
            .imageAlignment(.alignTopLeft)
            .contentTintColor(.systemPurple)
        XCTAssertTrue(imageView.image === image)
        XCTAssertEqual(imageView.imageScaling, .scaleProportionallyUpOrDown)
        XCTAssertEqual(imageView.imageAlignment, .alignTopLeft)
        XCTAssertEqual(imageView.contentTintColor, .systemPurple)
    }
}
