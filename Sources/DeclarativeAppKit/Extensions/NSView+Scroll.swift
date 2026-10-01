import AppKit

@MainActor
public extension NSView {

    /// Builds an `HScroll` and mounts it so it fills this view.
    ///
    /// The parameters match `HScroll.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addHScroll(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        safeArea: LayoutEdges = [],
        @NSViewBuilder content: () -> [NSView]
    ) -> HScroll {
        addContent(HScroll(
            alignment: alignment,
            spacing: spacing,
            showsIndicators: showsIndicators,
            content: content
        ), safeArea: safeArea)
    }

    /// Builds a `VScroll` and mounts it so it fills this view.
    ///
    /// The parameters match `VScroll.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addVScroll(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        safeArea: LayoutEdges = [],
        @NSViewBuilder content: () -> [NSView]
    ) -> VScroll {
        addContent(VScroll(
            alignment: alignment,
            spacing: spacing,
            showsIndicators: showsIndicators,
            content: content
        ), safeArea: safeArea)
    }
}
