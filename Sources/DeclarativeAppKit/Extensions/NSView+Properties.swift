import AppKit

@MainActor
public extension NSView {

    /// Runs `body` on this view, for AppKit properties without a dedicated modifier.
    @discardableResult
    func configure(_ body: (Self) -> Void) -> Self {
        body(self)
        return self
    }

    @discardableResult
    func alphaValue(_ value: CGFloat) -> Self {
        self.alphaValue = value
        return self
    }

    @discardableResult
    func isHidden(_ value: Bool) -> Self {
        self.isHidden = value
        return self
    }

    @discardableResult
    func toolTip(_ value: String?) -> Self {
        self.toolTip = value
        return self
    }

    @discardableResult
    func clipsToBounds(_ value: Bool) -> Self {
        self.clipsToBounds = value
        return self
    }

    @discardableResult
    func accessibilityLabel(_ value: String?) -> Self {
        setAccessibilityLabel(value)
        return self
    }

    /// Sets the help text, AppKit's counterpart of an accessibility hint.
    @discardableResult
    func accessibilityHelp(_ value: String?) -> Self {
        setAccessibilityHelp(value)
        return self
    }

    @discardableResult
    func accessibilityRole(_ value: NSAccessibility.Role?) -> Self {
        setAccessibilityRole(value)
        return self
    }

    @discardableResult
    func isAccessibilityElement(_ value: Bool) -> Self {
        setAccessibilityElement(value)
        return self
    }

    @discardableResult
    func accessibilityIdentifier(_ value: String?) -> Self {
        setAccessibilityIdentifier(value)
        return self
    }
}
