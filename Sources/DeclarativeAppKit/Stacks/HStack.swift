import AppKit

/// A horizontal stack of views, backed by `NSStackView`.
///
/// Constructing a stack does not mount it. Compose structural modifiers first and
/// mount the result with `addContent`, or use `addHStack` to build and mount in
/// one step.
///
/// On top of `NSStackView`, an `HStack` adds the `fill` alignment and keeps its padding
/// as a fixed distance on the top and bottom edges as well as along its axis.
public final class HStack: NSStackView {

    /// `NSStackView` has no fill alignment, so whether the elements are stretched is kept
    /// here. Setting `alignment` directly chooses one of AppKit's alignments and ends it.
    private var fillsCrossAxis = false
    private var crossAxis: [NSLayoutConstraint] = []

    /// - Parameters:
    ///   - alignment: How the elements line up on the vertical axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - content: The elements, in leading-to-trailing order.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        @NSViewBuilder content: () -> [NSView]
    ) {
        super.init(frame: .zero)
        orientation = .horizontal
        self.alignment(alignment)
        distribution = .fill
        self.spacing = spacing
        arrange(content())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("HStack is built in code and does not support init(coder:).")
    }

    /// Flipped, so the stack can be the document of a scroll view and start at its top.
    public override var isFlipped: Bool { true }

    public override var alignment: NSLayoutConstraint.Attribute {
        didSet { fillsCrossAxis = false }
    }

    public override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.deactivate(crossAxis)
        crossAxis = crossAxisConstraints(fills: fillsCrossAxis)
        NSLayoutConstraint.activate(crossAxis)
    }

    /// Sets how the elements line up on the vertical axis.
    @discardableResult
    public func alignment(_ value: VerticalAlignment) -> Self {
        self.alignment = value.stackAlignment
        fillsCrossAxis = value == .fill
        needsUpdateConstraints = true
        return self
    }
}
