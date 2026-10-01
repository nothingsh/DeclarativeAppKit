import AppKit

/// A view with a fixed intrinsic size, so hugging and compression resistance apply to it.
final class SizedView: NSView {
    private let size: NSSize

    init(width: CGFloat, height: CGFloat) {
        size = NSSize(width: width, height: height)
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SizedView is built in code.")
    }

    override var intrinsicContentSize: NSSize { size }
}
