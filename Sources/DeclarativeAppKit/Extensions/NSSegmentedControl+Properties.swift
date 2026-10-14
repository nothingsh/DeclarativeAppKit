import AppKit

@MainActor
public extension NSSegmentedControl {

    /// Selects a segment without sending the control's action. The index must be one of
    /// the segments, or `-1` to select none; AppKit raises an exception otherwise.
    @discardableResult
    func selectedSegment(_ value: Int) -> Self {
        self.selectedSegment = value
        return self
    }

    @discardableResult
    func selectedSegmentBezelColor(_ value: NSColor?) -> Self {
        self.selectedSegmentBezelColor = value
        return self
    }

    /// Sets how segments are selected, such as `.selectAny` or `.momentary`.
    @discardableResult
    func trackingMode(_ value: NSSegmentedControl.SwitchTracking) -> Self {
        self.trackingMode = value
        return self
    }
}
