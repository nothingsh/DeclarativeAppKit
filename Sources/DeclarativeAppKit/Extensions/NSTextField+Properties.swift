import AppKit

/// These apply to labels as well: a label is an `NSTextField` made with
/// `NSTextField(labelWithString:)` or `NSTextField(wrappingLabelWithString:)`.
@MainActor
public extension NSTextField {

    @discardableResult
    func stringValue(_ value: String) -> Self {
        self.stringValue = value
        return self
    }

    @discardableResult
    func attributedStringValue(_ value: NSAttributedString) -> Self {
        self.attributedStringValue = value
        return self
    }

    @discardableResult
    func placeholderString(_ value: String?) -> Self {
        self.placeholderString = value
        return self
    }

    @discardableResult
    func textColor(_ value: NSColor?) -> Self {
        self.textColor = value
        return self
    }

    /// `0` allows as many lines as the text needs.
    @discardableResult
    func maximumNumberOfLines(_ value: Int) -> Self {
        self.maximumNumberOfLines = value
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
