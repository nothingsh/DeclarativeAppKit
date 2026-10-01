import AppKit

/// A horizontally scrolling stack of views, backed by `NSScrollView`.
///
/// The elements are arranged by an embedded `HStack` whose height follows the scroll view
/// and whose width sets how far it scrolls. Constructing a scroll view does not mount it;
/// use `addContent`, or `addHScroll` to build and mount in one step.
///
/// The scroll view draws no background and does not adjust its content insets
/// automatically.
public final class HScroll: NSScrollView {

    /// The stack that arranges the elements, for configuration without a forwarding modifier.
    public let stack: HStack

    /// - Parameters:
    ///   - alignment: How the elements line up on the vertical axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - showsIndicators: Whether the horizontal scroller is shown.
    ///   - content: The elements, in leading-to-trailing order.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @NSViewBuilder content: () -> [NSView]
    ) {
        stack = HStack(alignment: alignment, spacing: spacing, content: content)
        super.init(frame: .zero)
        hasHorizontalScroller = showsIndicators
        mount(stack, scrolling: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("HScroll is built in code and does not support init(coder:).")
    }

    /// Sets whether the horizontal scroller is shown.
    @discardableResult
    public func showsIndicators(_ value: Bool) -> Self {
        hasHorizontalScroller = value
        return self
    }

    /// Sets how the elements line up on the vertical axis.
    @discardableResult
    public func alignment(_ value: VerticalAlignment) -> Self {
        stack.alignment(value)
        return self
    }

    /// Sets the distance between elements.
    @discardableResult
    public func spacing(_ value: CGFloat) -> Self {
        stack.spacing(value)
        return self
    }

    /// Sets the same padding on every edge, inside the scrolled content.
    @discardableResult
    public func padding(_ length: CGFloat) -> Self {
        stack.padding(length)
        return self
    }

    /// Sets the padding of the given edges, inside the scrolled content, and keeps the
    /// other edges as they are.
    @discardableResult
    public func padding(_ edges: LayoutEdges = .all, _ length: CGFloat = 16) -> Self {
        stack.padding(edges, length)
        return self
    }
}
