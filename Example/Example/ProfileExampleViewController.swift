import AppKit
import DeclarativeAppKit

/// A profile card built from stacks, with a status badge placed by `overlay`.
///
/// The content closures run once. Later changes go through the references kept
/// here, and Auto Layout resizes the card; nothing is re-rendered or bound.
final class ProfileExampleViewController: NSViewController {

    private static let shortBio = "Writes about analytical engines."
    private static let longBio = """
        Writes about analytical engines, and about what they could do beyond arithmetic: \
        compose music, draw figures, and manipulate any symbols whose relations can be \
        expressed. Her notes on the engine include what is often called the first published \
        program, a method for computing Bernoulli numbers.
        """

    private let bio = NSTextField(wrappingLabelWithString: ProfileExampleViewController.shortBio)
        .font(.preferredFont(forTextStyle: .body))

    private let status = fill(.systemGreen, cornerRadius: 8)
        .frame(width: 16, height: 16)
        .configure {
            $0.borderWidth = 2
            $0.borderColor = .windowBackgroundColor
        }

    // A toggle shows its alternate title while it is on.
    private let bioButton = NSButton(title: "Show long bio", target: nil, action: nil)
        .buttonType(.toggle)
        .alternateTitle("Show short bio")

    private let statusButton = NSButton(title: "Go away", target: nil, action: nil)
        .buttonType(.toggle)
        .alternateTitle("Come back")

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Profile"
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
        bioButton.target = self
        bioButton.action = #selector(toggleBio)
        statusButton.target = self
        statusButton.action = #selector(toggleStatus)

        addScreen {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    NSImageView()
                        .image(NSImage(systemSymbolName: "person.crop.circle.fill", accessibilityDescription: nil))
                        .imageScaling(.scaleProportionallyUpOrDown)
                        .contentTintColor(.systemIndigo)
                        .frame(width: 64, height: 64)
                        .overlay(alignment: .bottomTrailing) { status }
                    VStack(alignment: .leading, spacing: 2) {
                        NSTextField(labelWithString: "Ada Lovelace")
                            .font(.preferredFont(forTextStyle: .title2))
                        NSTextField(labelWithString: "Mathematician · London")
                            .font(.preferredFont(forTextStyle: .subheadline))
                            .textColor(.secondaryLabelColor)
                    }
                    Spacer()
                }
                bio
            }
            .card()

            HStack(spacing: 12) {
                bioButton
                statusButton
                Spacer()
            }

            note("""
                The bio label is kept as a property. Its text is changed through that reference, \
                and the card grows or shrinks with it. Resize the window to see the same layout \
                adapt.
                """)
        }
    }

    @objc private func toggleBio() {
        bio.stringValue(bioButton.state == .on ? Self.longBio : Self.shortBio)
    }

    @objc private func toggleStatus() {
        status.fillColor = statusButton.state == .on ? .systemGray : .systemGreen
    }
}
