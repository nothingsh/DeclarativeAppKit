import AppKit

@MainActor
public extension NSControl {

    @discardableResult
    func isEnabled(_ value: Bool) -> Self {
        self.isEnabled = value
        return self
    }

    @discardableResult
    func isHighlighted(_ value: Bool) -> Self {
        self.isHighlighted = value
        return self
    }

    @discardableResult
    func controlSize(_ value: NSControl.ControlSize) -> Self {
        self.controlSize = value
        return self
    }

    @discardableResult
    func font(_ value: NSFont?) -> Self {
        self.font = value
        return self
    }

    @discardableResult
    func alignment(_ value: NSTextAlignment) -> Self {
        self.alignment = value
        return self
    }

    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode) -> Self {
        self.lineBreakMode = value
        return self
    }
}
