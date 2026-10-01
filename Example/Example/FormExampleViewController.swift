import AppKit
import DeclarativeAppKit

/// A form whose controls are configured with modifiers and wired with AppKit's own
/// target–action and delegates.
final class FormExampleViewController: NSViewController, NSTextFieldDelegate {

    private let name = NSTextField().placeholderString("Name")

    private let email = NSTextField().placeholderString("Email")

    private let newsletter = NSSwitch().state(.on)

    private let frequency = NSSlider()
        .minValue(1)
        .maxValue(7)
        .doubleValue(3)
        .configure {
            $0.numberOfTickMarks = 7
            $0.allowsTickMarkValuesOnly = true
        }

    private let frequencyValue = NSTextField(labelWithString: "")
        .textColor(.secondaryLabelColor)

    private let submit = NSButton(title: "Submit", target: nil, action: nil)
        .isEnabled(false)

    private let result = NSTextField(wrappingLabelWithString: "")
        .font(.preferredFont(forTextStyle: .footnote))
        .textColor(.secondaryLabelColor)

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Form"
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
        name.delegate = self
        email.delegate = self
        frequency.target = self
        frequency.action = #selector(frequencyChanged)
        submit.target = self
        submit.action = #selector(submitForm)
        frequencyChanged()

        addScreen {
            sectionTitle("Contact")
            VStack(alignment: .fill, spacing: 12) {
                name
                email
            }
            .card()

            sectionTitle("Preferences")
            VStack(alignment: .fill, spacing: 12) {
                HStack(spacing: 8) {
                    NSTextField(labelWithString: "Newsletter")
                    Spacer()
                    newsletter
                }
                HStack(spacing: 8) {
                    NSTextField(labelWithString: "Issues per week")
                    Spacer()
                    frequencyValue
                }
                frequency
            }
            .card()

            HStack {
                submit
                Spacer()
            }
            result
            note("Submit is enabled once name and email are filled in.")
        }
    }

    func controlTextDidChange(_ notification: Notification) {
        submit.isEnabled(!name.stringValue.isEmpty && !email.stringValue.isEmpty)
    }

    @objc private func frequencyChanged() {
        frequencyValue.stringValue("\(frequency.integerValue)")
    }

    @objc private func submitForm() {
        result.stringValue("""
            Saved \(name.stringValue) <\(email.stringValue)>, \
            newsletter \(newsletter.state == .on ? "on" : "off"), \
            \(frequency.integerValue) per week.
            """)
    }
}
