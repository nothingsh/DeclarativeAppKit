import AppKit

@MainActor
public extension NSStepper {

    /// Sets the value without sending the stepper's action. AppKit clamps it to the
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

    /// AppKit's default maximum is 59.
    @discardableResult
    func maxValue(_ value: Double) -> Self {
        self.maxValue = value
        return self
    }

    @discardableResult
    func increment(_ value: Double) -> Self {
        self.increment = value
        return self
    }

    /// Whether stepping past one end of the range continues from the other. It does
    /// by default.
    @discardableResult
    func valueWraps(_ value: Bool) -> Self {
        self.valueWraps = value
        return self
    }

    /// Whether holding the stepper keeps stepping. It does by default.
    @discardableResult
    func autorepeat(_ value: Bool) -> Self {
        self.autorepeat = value
        return self
    }
}
