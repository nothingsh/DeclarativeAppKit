import AppKit

@MainActor
public extension NSSwitch {

    /// Sets the state without animation and without sending the switch's action.
    @discardableResult
    func state(_ value: NSControl.StateValue) -> Self {
        self.state = value
        return self
    }
}
