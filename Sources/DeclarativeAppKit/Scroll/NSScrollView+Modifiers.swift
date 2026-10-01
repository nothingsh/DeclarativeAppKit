import AppKit

@MainActor
public extension NSScrollView {

    @discardableResult
    func horizontalScrollElasticity(_ value: NSScrollView.Elasticity) -> Self {
        self.horizontalScrollElasticity = value
        return self
    }

    @discardableResult
    func verticalScrollElasticity(_ value: NSScrollView.Elasticity) -> Self {
        self.verticalScrollElasticity = value
        return self
    }

    @discardableResult
    func scrollerStyle(_ value: NSScroller.Style) -> Self {
        self.scrollerStyle = value
        return self
    }

    @discardableResult
    func autohidesScrollers(_ value: Bool) -> Self {
        self.autohidesScrollers = value
        return self
    }

    /// `HScroll` and `VScroll` draw no background by default.
    @discardableResult
    func drawsBackground(_ value: Bool) -> Self {
        self.drawsBackground = value
        return self
    }

    /// The color is only drawn while `drawsBackground` is `true`.
    @discardableResult
    func backgroundColor(_ value: NSColor) -> Self {
        self.backgroundColor = value
        return self
    }
}

@MainActor
extension NSScrollView {

    /// Makes `stack` the scrolled document. Its length along `orientation` sets how far
    /// the scroll view scrolls, and on the other axis it matches the visible area.
    ///
    /// The stack must be flipped, as `HStack` and `VStack` are, so that the content starts
    /// at the top of the scroll view.
    func mount(_ stack: NSStackView, scrolling orientation: NSUserInterfaceLayoutOrientation) {
        drawsBackground = false
        automaticallyAdjustsContentInsets = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        documentView = stack
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            orientation == .vertical
                ? stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                : stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
