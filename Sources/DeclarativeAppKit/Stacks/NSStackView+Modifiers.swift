import AppKit

@MainActor
public extension NSStackView {

    /// Sets the distance between elements.
    @discardableResult
    func spacing(_ value: CGFloat) -> Self {
        self.spacing = value
        return self
    }

    /// Sets the distance after `view`, in place of `spacing`.
    ///
    /// `view` must already be one of this stack's elements. The distance after the last
    /// element has no effect.
    @discardableResult
    func spacing(_ value: CGFloat, after view: NSView) -> Self {
        precondition(
            arrangedSubviews.contains(view),
            "spacing(_:after:) needs a view that is already an element of this stack."
        )
        setCustomSpacing(value, after: view)
        return self
    }

    /// Sets how the elements share the space along the stack's axis.
    @discardableResult
    func distribution(_ value: NSStackView.Distribution) -> Self {
        self.distribution = value
        return self
    }
}

@MainActor
extension NSStackView {

    /// Adds builder content as arranged subviews, in declaration order.
    func arrange(_ views: [NSView]) {
        precondition(
            Set(views.map(ObjectIdentifier.init)).count == views.count,
            "The same NSView appears more than once in stack content. A view belongs "
                + "to one parent, so NSStackView would keep a single arranged subview "
                + "and drop the repeat."
        )
        views.forEach { addArrangedSubview($0) }
    }
}
