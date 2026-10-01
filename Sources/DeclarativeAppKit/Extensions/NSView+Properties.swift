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

    @discardableResult
    func accessibilityIdentifier(_ value: String?) -> Self {
        setAccessibilityIdentifier(value)
        return self
    }
}
