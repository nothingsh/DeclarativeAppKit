import AppKit

@MainActor
public extension NSView {

    /// Rounds the corners of this view's layer, making the view layer-backed.
    ///
    /// It does not clip: content and subviews beyond the rounded corners stay visible.
    @discardableResult
    func cornerRadius(_ radius: CGFloat, curve: CALayerCornerCurve = .circular) -> Self {
        wantsLayer = true
        layer?.cornerRadius = radius
        layer?.cornerCurve = curve
        return self
    }

    /// Draws a border inside this view's bounds, following its corner radius. The view
    /// becomes layer-backed.
    ///
    /// The layer takes a `CGColor`, so the color is resolved once, when this is called. A
    /// dynamic color such as `.separatorColor` keeps that appearance and does not follow a
    /// later change between light and dark mode.
    @discardableResult
    func border(color: NSColor, width: CGFloat) -> Self {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
        return self
    }

    /// Draws a shadow behind this view's content, by setting its `shadow`.
    ///
    /// `opacity` multiplies the color's own alpha. `offset` is positive toward the right and
    /// the bottom, whether or not the view is flipped. As for `border`, the color is resolved
    /// once and does not follow a later change between light and dark mode.
    @discardableResult
    func shadow(
        color: NSColor = .shadowColor,
        opacity: CGFloat,
        radius: CGFloat,
        offset: CGSize = .zero
    ) -> Self {
        let shadow = NSShadow()
        shadow.shadowColor = color.withAlphaComponent(color.alphaComponent * opacity)
        shadow.shadowBlurRadius = radius
        // An `NSShadow` offset points up for a positive height, even in a flipped view.
        shadow.shadowOffset = NSSize(width: offset.width, height: -offset.height)
        self.shadow = shadow
        return self
    }
}
