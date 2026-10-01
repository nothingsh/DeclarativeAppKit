import AppKit

/// An off-screen window whose content view hosts the views under test.
/// Each test owns its window; nothing is shown and no shared window is touched.
@MainActor
final class LayoutTestHost {
    private let window: NSWindow

    var rootView: NSView { window.contentView! }

    init(size: CGSize, additionalSafeAreaInsets: NSEdgeInsets = NSEdgeInsetsZero) {
        _ = NSApplication.shared
        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        window.isReleasedWhenClosed = false
        rootView.additionalSafeAreaInsets = additionalSafeAreaInsets
        layout()
    }

    func layout() {
        rootView.layoutSubtreeIfNeeded()
    }

    /// Adds `view` at the root's top-leading corner without sizing it, so it takes
    /// the size its own constraints and content give it.
    func place(_ view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            view.topAnchor.constraint(equalTo: rootView.topAnchor)
        ])
        layout()
    }

    func resize(to size: CGSize) {
        window.setContentSize(size)
        layout()
    }
}
