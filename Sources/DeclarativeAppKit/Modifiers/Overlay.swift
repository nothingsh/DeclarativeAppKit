import AppKit

@MainActor
public extension NSView {

    /// Puts the view that `content` returns in front of this view's current subviews.
    ///
    /// The overlay is a subview of this view, and this view's content decides its size.
    /// A later call puts its overlay further front; subviews added afterwards, such as a
    /// later arranged subview, also go in front of it. With `.fill`, the overlay's hugging
    /// and compression resistance are lowered so that its intrinsic size cannot enlarge this
    /// view; an overlay whose own subviews require a minimum size still can.
    ///
    /// Mouse events follow AppKit hit testing: an overlay that handles them receives the
    /// ones inside its bounds and blocks the content behind it.
    @discardableResult
    func overlay(alignment: LayoutAlignment = .fill, content: () -> NSView) -> Self {
        addDecoration(content(), alignment: alignment, behind: false)
        return self
    }
}
