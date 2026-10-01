import AppKit

/// An `NSButton` shows its `title` and `image` in the off state and its `alternateTitle`
/// and `alternateImage` in the on state, for the button types that have one.
@MainActor
public extension NSButton {

    @discardableResult
    func title(_ value: String) -> Self {
        self.title = value
        return self
    }

    @discardableResult
    func attributedTitle(_ value: NSAttributedString) -> Self {
        self.attributedTitle = value
        return self
    }

    @discardableResult
    func image(_ value: NSImage?) -> Self {
        self.image = value
        return self
    }

    @discardableResult
    func alternateTitle(_ value: String) -> Self {
        self.alternateTitle = value
        return self
    }

    @discardableResult
    func alternateImage(_ value: NSImage?) -> Self {
        self.alternateImage = value
        return self
    }

    @discardableResult
    func imagePosition(_ value: NSControl.ImagePosition) -> Self {
        self.imagePosition = value
        return self
    }

    @discardableResult
    func bezelStyle(_ value: NSButton.BezelStyle) -> Self {
        self.bezelStyle = value
        return self
    }

    /// Sets how the button behaves when clicked, such as `.toggle` or `.switch`.
    @discardableResult
    func buttonType(_ value: NSButton.ButtonType) -> Self {
        setButtonType(value)
        return self
    }

    /// Sets the state without sending the button's action.
    @discardableResult
    func state(_ value: NSControl.StateValue) -> Self {
        self.state = value
        return self
    }

    @discardableResult
    func contentTintColor(_ value: NSColor?) -> Self {
        self.contentTintColor = value
        return self
    }
}
