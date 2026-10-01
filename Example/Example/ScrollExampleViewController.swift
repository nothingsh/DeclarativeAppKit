import AppKit
import DeclarativeAppKit

/// Horizontal scroll views nested in a vertical one, and rows appended at runtime.
final class ScrollExampleViewController: NSViewController {

    private static let tags = [
        "AppKit", "Auto Layout", "Stacks", "Padding", "Frame", "Background",
        "Overlay", "Spacer", "Scroll", "RTL",
    ]

    private let rows = VStack(alignment: .fill, spacing: 8) {}

    private let addRowButton = NSButton(title: "Add row", target: nil, action: nil)

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Scrolling"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("The example screens are built in code.")
    }

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addRowButton.target = self
        addRowButton.action = #selector(addRow)
        for _ in 1...6 { addRow() }

        addScreen {
            sectionTitle("Tags · HScroll")
            HScroll(spacing: 8, showsIndicators: false) {
                for tag in Self.tags { chip(tag) }
            }

            sectionTitle("Cards · HScroll")
            HScroll(alignment: .top, spacing: 12) {
                for index in 1...8 { card(index) }
            }

            HStack {
                sectionTitle("Rows · VScroll")
                Spacer()
                addRowButton
            }
            note("Add row appends to the stack kept as a property; the scrollable length grows with it.")
            rows
        }
    }

    private func chip(_ text: String) -> NSView {
        VStack {
            NSTextField(labelWithString: text)
                .font(.preferredFont(forTextStyle: .subheadline))
                .textColor(.systemBlue)
        }
        .padding(horizontal: 12, vertical: 6)
        .background { fill(NSColor.systemBlue.withAlphaComponent(0.12), cornerRadius: 8) }
    }

    private func card(_ index: Int) -> NSView {
        VStack(alignment: .leading, spacing: 4) {
            NSImageView()
                .image(NSImage(systemSymbolName: "square.stack.3d.up.fill", accessibilityDescription: nil))
                .imageScaling(.scaleProportionallyUpOrDown)
                .contentTintColor(.systemOrange)
                .frame(width: 32, height: 32)
            NSTextField(labelWithString: "Card \(index)")
                .font(.preferredFont(forTextStyle: .headline))
            NSTextField(wrappingLabelWithString:
                index.isMultiple(of: 3) ? "A longer caption that wraps onto a few lines." : "Short caption")
                .font(.preferredFont(forTextStyle: .footnote))
                .textColor(.secondaryLabelColor)
        }
        .card(padding: 12)
        .frame(width: 160)
    }

    @objc private func addRow() {
        let number = rows.arrangedSubviews.count + 1
        rows.addArrangedSubview(
            HStack(spacing: 8) {
                NSTextField(labelWithString: "Row \(number)")
                Spacer(minLength: 8)
                NSTextField(labelWithString: number.isMultiple(of: 2) ? "even" : "odd")
                    .textColor(.secondaryLabelColor)
            }
            .card(padding: 12)
        )
    }
}
