import AppKit

/// An `NSTextView` does not scroll by itself. For a scrolling text view, start from
/// `NSTextView.scrollableTextView()` and configure its `documentView`.
@MainActor
public extension NSTextView {

    @discardableResult
    func string(_ value: String) -> Self {
        self.string = value
        return self
    }

    @discardableResult
    func font(_ value: NSFont?) -> Self {
        self.font = value
        return self
    }

    @discardableResult
    func textColor(_ value: NSColor?) -> Self {
        self.textColor = value
        return self
    }

    @discardableResult
    func alignment(_ value: NSTextAlignment) -> Self {
        self.alignment = value
        return self
    }

    @discardableResult
    func isEditable(_ value: Bool) -> Self {
        self.isEditable = value
        return self
    }

    @discardableResult
    func isSelectable(_ value: Bool) -> Self {
        self.isSelectable = value
        return self
    }
}
