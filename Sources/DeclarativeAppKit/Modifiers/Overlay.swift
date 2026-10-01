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
    /// `offset` moves the overlay from where `alignment` puts it: x is positive toward the
    /// right and y toward the bottom. It is passed to Auto Layout as it is, which reverses
    /// the horizontal direction in a right-to-left layout; adjust the value yourself if
    /// that is not what you want. `.fill` takes no offset. Before macOS 14 a view clips its subviews by default, so
    /// the part of an overlay moved outside this view is not drawn there unless
    /// `clipsToBounds` is off.
    ///
    /// Mouse events follow AppKit hit testing: an overlay that handles them receives the
    /// ones inside its bounds and blocks the content behind it. The part of an overlay
    /// outside this view receives none.
    @discardableResult
    func overlay(
        alignment: LayoutAlignment = .fill,
        offset: CGPoint = .zero,
        content: () -> NSView
    ) -> Self {
        addDecoration(content(), alignment: alignment, offset: offset, behind: false)
        return self
    }
}
