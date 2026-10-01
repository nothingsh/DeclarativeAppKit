import AppKit

@MainActor
public extension NSView {

    /// Sets how strongly this view resists growing beyond its intrinsic size on `orientation`.
    ///
    /// When a stack has extra space, the view with the lowest hugging priority grows.
    @discardableResult
    func contentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        setContentHuggingPriority(priority, for: orientation)
        return self
    }

    /// Sets how strongly this view resists shrinking below its intrinsic size on `orientation`.
    ///
    /// When a stack runs out of space, the view with the lowest compression resistance
    /// shrinks first.
    @discardableResult
    func compressionResistancePriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        setContentCompressionResistancePriority(priority, for: orientation)
        return self
    }
}
