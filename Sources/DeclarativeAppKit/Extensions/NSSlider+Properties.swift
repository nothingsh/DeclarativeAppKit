import AppKit

@MainActor
public extension NSSlider {

    /// Sets the value without sending the slider's action. AppKit clamps it to the
    /// current range, so set `minValue` and `maxValue` first.
    @discardableResult
    func doubleValue(_ value: Double) -> Self {
        self.doubleValue = value
        return self
    }

    @discardableResult
    func minValue(_ value: Double) -> Self {
        self.minValue = value
        return self
    }

    @discardableResult
    func maxValue(_ value: Double) -> Self {
        self.maxValue = value
        return self
    }

    @discardableResult
    func trackFillColor(_ value: NSColor?) -> Self {
        self.trackFillColor = value
        return self
    }
}
