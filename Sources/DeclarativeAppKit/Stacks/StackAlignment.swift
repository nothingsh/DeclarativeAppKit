import AppKit

/// Cross-axis alignment of the elements in a `VStack`.
public enum HorizontalAlignment {
    case leading
    case center
    case trailing
    /// An addition with no SwiftUI counterpart: every element is stretched
    /// to the stack's width, inside its padding.
    case fill

    /// `NSStackView` has no fill alignment, so `fill` falls back to `leading` and the
    /// stack's own cross-axis constraints do the stretching.
    var stackAlignment: NSLayoutConstraint.Attribute {
        switch self {
        case .leading, .fill: return .leading
        case .center: return .centerX
        case .trailing: return .trailing
        }
    }
}

/// Cross-axis alignment of the elements in an `HStack`.
///
/// The baseline cases use AppKit's own baseline alignment; they are not SwiftUI's
/// alignment guides.
public enum VerticalAlignment {
    case top
    case center
    case bottom
    case firstTextBaseline
    case lastTextBaseline
    /// An addition with no SwiftUI counterpart: every element is stretched
    /// to the stack's height, inside its padding.
    case fill

    /// `NSStackView` has no fill alignment, so `fill` falls back to `top` and the
    /// stack's own cross-axis constraints do the stretching.
    var stackAlignment: NSLayoutConstraint.Attribute {
        switch self {
        case .top, .fill: return .top
        case .center: return .centerY
        case .bottom: return .bottom
        case .firstTextBaseline: return .firstBaseline
        case .lastTextBaseline: return .lastBaseline
        }
    }
}
