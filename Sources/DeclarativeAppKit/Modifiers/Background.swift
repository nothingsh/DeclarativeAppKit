import AppKit

@MainActor
public extension NSStackView {

    /// Puts the view that `content` returns behind the stack's content, covering the whole
    /// stack including its padding by default.
    ///
    /// The decoration is a subview of the stack, not an arranged subview, so it takes no
    /// part in the stack's arrangement and the stack's content decides its size. A later
    /// call puts its decoration further back. With `.fill`, the decoration's hugging and
    /// compression resistance are lowered so that its intrinsic size cannot enlarge the
    /// stack; a decoration whose own subviews require a minimum size still can.
    @discardableResult
    func background(alignment: LayoutAlignment = .fill, content: () -> NSView) -> Self {
        addDecoration(content(), alignment: alignment, behind: true)
        return self
    }

    /// Fills the stack, including its padding, with `color`.
    ///
    /// An `NSView` has no background color of its own, so this adds a borderless `NSBox`
    /// behind the stack's content, as `background(alignment:content:)` would. The color
    /// follows the appearance when it is a dynamic color.
    @discardableResult
    func background(_ color: NSColor) -> Self {
        let fill = NSBox()
        fill.boxType = .custom
        fill.borderWidth = 0
        fill.fillColor = color
        return background { fill }
    }
}
