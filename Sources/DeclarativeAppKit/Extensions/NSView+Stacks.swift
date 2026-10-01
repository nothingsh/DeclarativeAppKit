import AppKit

@MainActor
public extension NSView {

    /// Builds an `HStack` and mounts it so it fills this view.
    ///
    /// The parameters match `HStack.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addHStack(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        safeArea: LayoutEdges = [],
        @NSViewBuilder content: () -> [NSView]
    ) -> HStack {
        addContent(HStack(alignment: alignment, spacing: spacing, content: content), safeArea: safeArea)
    }

    /// Builds a `VStack` and mounts it so it fills this view.
    ///
    /// The parameters match `VStack.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addVStack(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        safeArea: LayoutEdges = [],
        @NSViewBuilder content: () -> [NSView]
    ) -> VStack {
        addContent(VStack(alignment: alignment, spacing: spacing, content: content), safeArea: safeArea)
    }
}
