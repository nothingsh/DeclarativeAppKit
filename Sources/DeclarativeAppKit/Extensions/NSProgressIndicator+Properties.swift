import AppKit

@MainActor
public extension NSProgressIndicator {

    /// Sets the style, `.bar` or `.spinning`.
    @discardableResult
    func style(_ value: NSProgressIndicator.Style) -> Self {
        self.style = value
        return self
    }

    /// An indicator is indeterminate by default. Set this to `false` to show `doubleValue`.
    @discardableResult
    func isIndeterminate(_ value: Bool) -> Self {
        self.isIndeterminate = value
        return self
    }

    /// Sets the progress. AppKit clamps it to the current range, so set `minValue` and
    /// `maxValue` first.
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
    func isDisplayedWhenStopped(_ value: Bool) -> Self {
        self.isDisplayedWhenStopped = value
        return self
    }

    /// Starts or stops the animation of an indeterminate indicator.
    @discardableResult
    func isAnimating(_ value: Bool) -> Self {
        if value {
            startAnimation(nil)
        } else {
            stopAnimation(nil)
        }
        return self
    }
}
