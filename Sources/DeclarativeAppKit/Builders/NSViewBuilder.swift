import AppKit

/// Collects the views written in a content closure, in declaration order.
///
/// Accepts a view, an optional view, an array of views, `if` / `else`, `switch`,
/// `for`, `if #available` and empty content. An expression that is not an `NSView`
/// fails to compile rather than being dropped.
@resultBuilder
public enum NSViewBuilder {

    public static func buildBlock(_ components: [NSView]...) -> [NSView] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: NSView) -> [NSView] {
        [expression]
    }

    public static func buildExpression(_ expression: NSView?) -> [NSView] {
        expression.map { [$0] } ?? []
    }

    public static func buildExpression(_ expression: [NSView]) -> [NSView] {
        expression
    }

    public static func buildOptional(_ component: [NSView]?) -> [NSView] {
        component ?? []
    }

    public static func buildEither(first component: [NSView]) -> [NSView] {
        component
    }

    public static func buildEither(second component: [NSView]) -> [NSView] {
        component
    }

    public static func buildArray(_ components: [[NSView]]) -> [NSView] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [NSView]) -> [NSView] {
        component
    }
}
