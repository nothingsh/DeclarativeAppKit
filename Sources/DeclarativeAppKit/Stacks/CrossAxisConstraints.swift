import AppKit

@MainActor
extension NSStackView {

    /// Builds the required cross-axis constraints `NSStackView` does not provide.
    ///
    /// `NSStackView` has no fill alignment, keeps its cross-axis `edgeInsets` only at a
    /// low priority, and centers on its own center rather than between the insets. These
    /// constraints make padding a fixed distance on every edge, center between the padded
    /// edges when the stack's `alignment` is the center, and stretch the elements when
    /// `fills` is `true`.
    ///
    /// Detached elements, such as hidden ones, are left out: `NSStackView` keeps them in the
    /// hierarchy, and a constraint on one would let it go on sizing the stack.
    func crossAxisConstraints(fills: Bool) -> [NSLayoutConstraint] {
        let isVertical = orientation == .vertical
        let start: NSLayoutConstraint.Attribute = isVertical ? .leading : .top
        let end: NSLayoutConstraint.Attribute = isVertical ? .trailing : .bottom
        let center: NSLayoutConstraint.Attribute = isVertical ? .centerX : .centerY
        let startInset = isVertical ? edgeInsets.left : edgeInsets.top
        let endInset = isVertical ? edgeInsets.right : edgeInsets.bottom
        let detached = detachedViews

        func constraint(
            _ view: NSView,
            _ attribute: NSLayoutConstraint.Attribute,
            _ relation: NSLayoutConstraint.Relation,
            _ constant: CGFloat
        ) -> NSLayoutConstraint {
            NSLayoutConstraint(
                item: view,
                attribute: attribute,
                relatedBy: relation,
                toItem: self,
                attribute: attribute,
                multiplier: 1,
                constant: constant
            )
        }

        return arrangedSubviews.filter { !detached.contains($0) }.flatMap { view in
            var constraints = [
                constraint(view, start, fills ? .equal : .greaterThanOrEqual, startInset),
                constraint(view, end, fills ? .equal : .lessThanOrEqual, -endInset)
            ]
            if alignment == center {
                constraints.append(constraint(view, center, .equal, (startInset - endInset) / 2))
            }
            return constraints
        }
    }
}
