# DeclarativeAppKit

**English** | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

A lightweight declarative layout library for AppKit, built on plain `NSView` and Auto Layout with no third-party dependencies.

It introduces no custom rendering layer and no parallel view hierarchy. What you get back is always a real `NSView` or subclass, so it mixes freely with existing AppKit code.

For UIKit, see the sibling package [DeclarativeUIKit](https://github.com/nothingsh/DeclarativeUIKit). The two share their vocabulary and do not depend on each other.

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    NSTextField(labelWithString: "Ada Lovelace")
        .font(.preferredFont(forTextStyle: .headline))
    NSTextField(labelWithString: "Mathematician")
        .font(.preferredFont(forTextStyle: .subheadline))
        .textColor(.secondaryLabelColor)
}
```

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [`addContent(_:)`](#addcontent_)
  - [Stacks](#stacks)
  - [Content closures](#content-closures)
  - [Property modifiers](#property-modifiers)
  - [Padding](#padding)
  - [Frame](#frame)
  - [Background and overlay](#background-and-overlay)
  - [Spacer and layout priorities](#spacer-and-layout-priorities)
  - [Scroll views](#scroll-views)
- [Roadmap](#roadmap)
- [Known limitations](#known-limitations)
- [Development](#development)
- [License](#license)

## Requirements

- macOS 11.0+
- Swift 5.9+
- No external dependencies, system AppKit only

## Installation

Swift Package Manager. In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeAppKit.git", from: "0.1.0")
]
```

Or in Xcode, choose File → Add Package Dependencies and enter `https://github.com/nothingsh/DeclarativeAppKit`.

## Usage

### `addContent(_:)`

Mounts a view into a parent and makes it fill that parent, or the parent's safe area on the edges you choose.

```swift
@discardableResult
func addContent<Content: NSView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(NSTextField(labelWithString: "Title"))   // returns the NSTextField
view.addContent(customView)                                          // the return value can be ignored
view.addContent(page, safeArea: .all)                                // stays inside the safe area
```

- By default pins all four edges of the content to the parent's edges, so it fills the bounds and ignores the safe area.
- The edges named in `safeArea` are pinned to the parent's `safeAreaLayoutGuide` instead. The content, including any background it draws, stays inside the safe area on those edges and follows it as it changes. Name only some edges to let the others reach the parent's edges: `safeArea: .top` keeps content clear of a full-size-content title bar while it still reaches the other three edges.
- Uses `leadingAnchor` and `trailingAnchor`, so the layout mirrors in right-to-left languages. `LayoutEdges` is the same option set that `padding` uses.
- Returns the same instance that was passed in, keeping its concrete type.
- Leaves the content's own size constraints untouched.

A view is meant to be mounted once. Calling this again for content that already has a superview logs a note through `NSLog`, removes the content from its current parent — which drops the constraints tying it to the old hierarchy — and mounts it again. Constraints never accumulate, but the content moves to the front of the subview order.

### Stacks

`HStack` and `VStack` arrange views along an axis. Both are `NSStackView` subclasses, so every native stack API stays available.

```swift
init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0, @NSViewBuilder content: () -> [NSView])   // VStack
init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0, @NSViewBuilder content: () -> [NSView])     // HStack
```

```swift
let column = VStack(alignment: .leading, spacing: 4) {
    name
    role
    HStack(spacing: 8) {
        icon
        detail
    }
}

view.addContent(column)
```

- `alignment` is the cross axis. A `VStack` takes a `HorizontalAlignment` — `leading`, `center`, `trailing`, `fill`. An `HStack` takes a `VerticalAlignment` — `top`, `center`, `bottom`, `firstTextBaseline`, `lastTextBaseline`, `fill`. The baseline cases use AppKit's own baseline alignment.
- `fill` has no SwiftUI counterpart and stretches every element across the cross axis. `NSStackView` has no such alignment of its own; `HStack` and `VStack` add it.
- `spacing` defaults to `0`, so the gaps you see are the ones you write. This differs from SwiftUI, whose default spacing is contextual, and from a plain `NSStackView`, whose default is `8`.
- `distribution` is `.fill` and is configured with a modifier rather than an initializer argument. A plain `NSStackView` defaults to `.gravityAreas`.
- Constructing a stack does not mount it anywhere, and the elements keep their declaration order.
- A hidden element takes no space, as in `NSStackView`.
- Both stacks are flipped, so their own coordinate system starts at the top-left corner.

To build and mount in one step:

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` and `addVStack` take the same parameters as the initializers plus `safeArea`, mount the new stack through `addContent`, and return it. As with `addContent`, the stack fills the parent unless you name safe-area edges:

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

Stack modifiers return the stack, so it can be configured after construction or after mounting:

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` and `distribution(_:)` work on any `NSStackView`. `alignment(_:)` is defined per direction, so it takes a `VerticalAlignment` on `HStack` and a `HorizontalAlignment` on `VStack`.

### Content closures

Stack content is written with `@NSViewBuilder`, which collects views in declaration order and accepts:

| Form | Example |
| --- | --- |
| A view | `NSButton()` |
| An optional view | `subtitle`, where `subtitle: NSTextField?` — `nil` contributes nothing |
| An array of views | `rows`, where `rows: [NSView]` |
| `if` and `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(macOS 14, *) { modernView }` |
| Nothing at all | `VStack {}` |

An expression that is not an `NSView` fails to compile rather than being silently dropped.

An `NSView` belongs to one parent, so the same instance must not appear twice in one content closure. That is a programming error: it traps with a message instead of quietly collapsing into a single element.

### Property modifiers

Property modifiers set an AppKit property on the receiver and return the same instance as `Self`, so the concrete type survives the chain and type-specific modifiers stay available after general ones. When the same property is set twice, the last call wins.

```swift
let title = NSTextField(wrappingLabelWithString: "Title")
    .font(.preferredFont(forTextStyle: .title2))
    .maximumNumberOfLines(0)
    .accessibilityIdentifier("title")

title.stringValue("Updated")   // later updates go through the same reference
```

Each modifier has the name and the type of the AppKit property it sets.

| Type | Modifiers |
| --- | --- |
| `NSView` and any subclass | `configure`, `alphaValue`, `isHidden`, `toolTip`, `clipsToBounds`, `accessibilityLabel`, `accessibilityIdentifier` |
| `NSControl` and any subclass | `isEnabled`, `isHighlighted`, `controlSize`, `font`, `alignment`, `lineBreakMode` |
| `NSTextField` | `stringValue`, `attributedStringValue`, `placeholderString`, `textColor`, `maximumNumberOfLines`, `isEditable`, `isSelectable` |
| `NSButton` | `title`, `attributedTitle`, `image`, `alternateTitle`, `alternateImage`, `imagePosition`, `bezelStyle`, `buttonType`, `state`, `contentTintColor` |
| `NSTextView` | `string`, `font`, `textColor`, `alignment`, `isEditable`, `isSelectable` |
| `NSSlider` | `doubleValue`, `minValue`, `maxValue`, `trackFillColor` |
| `NSSwitch` | `state` |
| `NSImageView` | `image`, `imageScaling`, `imageAlignment`, `contentTintColor` |

They are not an exhaustive mirror of AppKit; for anything else, use `configure`, which hands you the view with its concrete type:

```swift
let avatar = NSImageView()
    .image(photo)
    .imageScaling(.scaleProportionallyUpOrDown)
    .configure {
        $0.wantsLayer = true
        $0.layer?.cornerRadius = 24
    }
```

- A label is an `NSTextField`. Make one with AppKit's `NSTextField(labelWithString:)` or `NSTextField(wrappingLabelWithString:)`; every `NSTextField` and `NSControl` modifier applies to it. The library adds no label type.
- `maximumNumberOfLines(0)` lets a wrapping label use as many lines as it needs; under Auto Layout its height follows the available width.
- `accessibilityLabel` and `accessibilityIdentifier` call AppKit's `setAccessibilityLabel(_:)` and `setAccessibilityIdentifier(_:)`.

```swift
let play = NSButton()
    .buttonType(.toggle)
    .title("Play")
    .alternateTitle("Pause")
    .image(playIcon)
    .alternateImage(pauseIcon)

let volume = NSSlider()
    .minValue(0)
    .maxValue(10)
    .doubleValue(7)
```

- An `NSButton` shows `title` and `image` in its off state and `alternateTitle` and `alternateImage` in its on state, for the button types that have one. `buttonType` calls `setButtonType(_:)`.
- Events use AppKit's own target–action: set `play.target` and `play.action`. The modifiers add no targets and no closure handlers.
- Setting a value with `state` or `doubleValue` is not a user event and sends no action, as with the AppKit properties.
- `NSSlider` clamps `doubleValue` to its current range, so set `minValue` and `maxValue` before `doubleValue`.
- An `NSTextView` does not scroll by itself. For a scrolling text view, start from AppKit's `NSTextView.scrollableTextView()` and configure its `documentView`.
- Delegates and editing stay AppKit's own. The modifiers set no delegate, and there is no two-way binding or input validation.

### Padding

Padding is a stack modifier. It sets the stack's `edgeInsets` and returns the same stack.

```swift
func padding(_ length: CGFloat) -> Self
func padding(_ edges: LayoutEdges = .all, _ length: CGFloat = 16) -> Self
func padding(horizontal: CGFloat, vertical: CGFloat) -> Self
func padding(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) -> Self
func padding(_ edges: LayoutEdges, _ length: CGFloat, others: CGFloat) -> Self
func padding(_ insets: NSDirectionalEdgeInsets) -> Self
```

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(.horizontal, 16)
.padding(.vertical, 12)
```

```swift
stack.padding(horizontal: 16, vertical: 12)                   // one value per axis
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // every edge differs
stack.padding(.top, 24, others: 8)                            // one edge, the rest alike
```

- Padding counts toward the stack's size: a stack whose content is 20 × 30 is 40 × 50 with `.padding(10)`.
- It behaves like a property. `padding(_:_:)` changes only the edges you name and keeps the others, so `.padding(.horizontal, 16).padding(.vertical, 12)` sets all four. Every other form sets all four edges in one call. A later call replaces earlier values rather than adding to them.
- `LayoutEdges` is an option set of `top`, `leading`, `bottom`, `trailing`, plus `horizontal`, `vertical` and `all`. Horizontal edges are `leading` and `trailing`, so they mirror in right-to-left languages.
- On an `HStack` or `VStack`, padding is a fixed distance on all four edges: an element that is too large is compressed rather than allowed into the padding, and `center` alignment centers between the padded edges. A plain `NSStackView` keeps AppKit's own behavior; see [Known limitations](#known-limitations).
- Padding never includes the safe area. To keep content inside the safe area, mount it with `safeArea`; see [`addContent(_:)`](#addcontent_).
- To pad a single view, put it in a stack: `VStack { label }.padding(16)`.

### Frame

`frame` adds size constraints to the view itself and returns it as `Self`, so the chain keeps its concrete type. As in SwiftUI, there is one form for a fixed size and one for a size range.

```swift
func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self
func frame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil,
           minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self
func frame(aspectRatio: CGFloat?) -> Self
```

```swift
let avatar = NSImageView()
    .frame(width: 48, height: 48)
    .image(photo)

let button = NSButton().frame(minWidth: 88)
let label = NSTextField(wrappingLabelWithString: text).frame(maxWidth: 200)
let banner = NSImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- It sets `translatesAutoresizingMaskIntoConstraints` to `false` and uses required `widthAnchor` / `heightAnchor` constraints: `==` for a fixed length, `>=` for a minimum, `<=` for a maximum.
- Each call redefines the axes it names and leaves the other axis alone. Calling `frame(width: 100)` and then `frame(width: 120)` updates the same constraint. A fixed width removes an earlier minimum or maximum width, and a range removes an earlier fixed width, so switching between them never conflicts. In the range form, naming only one bound of an axis removes the other: `frame(minWidth: 40)` after `frame(maxWidth: 200)` leaves only the minimum.
- `.infinity` is accepted as a maximum and means no upper bound; it adds no constraint.
- `frame(aspectRatio:)` keeps width equal to the ratio times height, as in SwiftUI (`16 / 9` is wider than tall). Pair it with a fixed width or height to derive the other length; fixing both as well conflicts. A repeated call replaces the ratio, and `nil` removes it.
- Only the constraints `frame` created are updated or removed. Size constraints you add yourself are never touched.
- A negative or non-finite fixed length or minimum, a negative or NaN maximum, a minimum above the maximum, or an aspect ratio that is not finite and positive is a programming error and traps with a message.

### Background and overlay

A decoration is added as a subview of the view it decorates and pinned with constraints. Every form returns the same view as `Self`. No container view is inserted and there is no `ZStack`.

```swift
// NSStackView
func background(_ color: NSColor) -> Self
func background(alignment: LayoutAlignment = .fill, content: () -> NSView) -> Self

// NSView
func overlay(alignment: LayoutAlignment = .fill, content: () -> NSView) -> Self
```

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)
.background(.controlBackgroundColor)

let rounded = VStack { name }
    .padding(16)
    .background {
        NSBox().configure {
            $0.boxType = .custom
            $0.borderWidth = 0
            $0.cornerRadius = 12
            $0.fillColor = .controlBackgroundColor
        }
    }

let avatar = NSImageView()
    .frame(width: 48, height: 48)
    .image(photo)
    .overlay(alignment: .bottomTrailing) { statusDot }
```

- `background(_:)` is a stack modifier. An `NSView` has no background color of its own, so it puts a borderless `NSBox` filled with the color behind the stack's content. A dynamic color such as `.controlBackgroundColor` follows the light and dark appearance. Controls that draw a background, such as `NSTextField` and `NSScrollView`, have their own AppKit properties for it.
- `background { ... }` is a stack modifier too. The view goes behind the stack's content and, with the default `.fill`, covers the whole stack, padding included. To put a background behind a single view, put that view in a stack: `VStack { label }.padding(8).background { badgeShape }`.
- `overlay` works on any view and goes in front of the view's current subviews and, with the default `.fill`, covers the whole view. Subviews added later, such as arranged subviews appended afterwards, go in front of it.
- The decorated view's content decides its size. With `.fill`, the decoration's hugging and compression resistance are set to `.fittingSizeCompression`, so a large image can't enlarge the view. A decoration whose own subviews require a minimum size, such as a stack of labels, still can.
- `LayoutAlignment` is `fill`, `center`, `top`, `bottom`, `leading`, `trailing`, `topLeading`, `topTrailing`, `bottomLeading` or `bottomTrailing`. `fill` stretches the decoration over the view. The other cases keep the decoration's own size and place it at that position. `leading` and `trailing` mirror in right-to-left languages.
- Decorations add up, as in SwiftUI: a later background goes further back, and a later `overlay` goes further front.
- A decoration view is meant to be added once. If it already has a superview, that is reported and it is removed first, dropping its existing constraints, then added again.
- Mouse events follow AppKit hit testing. A background sits behind the content, so it never blocks controls. An overlay that handles mouse events receives the ones inside its bounds and blocks what is behind it.

### Spacer and layout priorities

`Spacer` is an empty view that takes the remaining length along the axis of the stack it is in. Layout priorities are set with two modifiers on any view that return the same view as `Self`.

```swift
public init(minLength: CGFloat = 0)   // Spacer

// NSView
func contentHuggingPriority(_ priority: NSLayoutConstraint.Priority,
                            for orientation: NSLayoutConstraint.Orientation) -> Self
func compressionResistancePriority(_ priority: NSLayoutConstraint.Priority,
                                   for orientation: NSLayoutConstraint.Orientation) -> Self
```

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

- A spacer gives way before views with content: on the stack's axis its hugging priority is `.fittingSizeCompression`, so it absorbs the extra space and the other views keep their intrinsic size. On the cross axis it has no size of its own and takes none unless the stack's alignment is `fill`.
- Several spacers in one stack share the extra space equally.
- `minLength` is a required minimum. When the stack can't fit it, the other views shrink according to their compression resistance; lower one with `compressionResistancePriority` to choose which view gives way first. If the fixed sizes in a stack can't fit at all, the required constraints conflict and AppKit breaks one of them, as with any Auto Layout.
- On an unbounded axis, such as the scrolling axis of a scroll view, there is no remaining length, so a spacer is only `minLength` long.
- The axis is read when the spacer is added to an `NSStackView`, whether from a content closure or with `addArrangedSubview`. Changing that stack's `orientation` afterwards isn't followed. A spacer outside an `NSStackView` has no effect, and adding it to one is reported.
- For a fixed gap, use `frame` on an empty view or the stack's `spacing`.
- These priorities are AppKit's content hugging and compression resistance, not SwiftUI's `layoutPriority`: they only decide between views that would otherwise be sized from their intrinsic content size.

### Scroll views

`HScroll` and `VScroll` are scrolling stacks: the elements you list are arranged by an embedded `HStack` or `VStack`, so there is no need to write a stack inside. Both are `NSScrollView` subclasses, so every native scroll view API stays available.

```swift
init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0, showsIndicators: Bool = true,
     @NSViewBuilder content: () -> [NSView])     // HScroll
init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0, showsIndicators: Bool = true,
     @NSViewBuilder content: () -> [NSView])     // VScroll
```

```swift
let tagRow = HScroll(spacing: 8, showsIndicators: false) {
    for name in tagNames { chip(name) }
}
.padding(.horizontal, 16)

view.addVScroll(alignment: .fill, spacing: 12) {
    title
    body
    tagRow
}
.padding(16)
```

- `alignment`, `spacing` and the content closure mean the same as for `HStack` and `VStack`, and take the same defaults. `addHScroll` and `addVScroll` take the same parameters plus `safeArea`, mount through `addContent`, and return the scroll view.
- The embedded stack is the scroll view's `documentView`, so the elements decide the scrollable length. On the other axis the stack matches the visible area: a `VScroll`'s stack is as wide as it, an `HScroll`'s stack as tall, and `alignment` places the elements across it. When the scroll view resizes or an element changes, such as a label wrapping onto more lines, the scrollable length follows.
- The content starts at the top. Content shorter than the scroll view keeps its own length, stays at the top and is not stretched to fill it.
- The scrolling axis is unbounded, so a `Spacer` in a scroll view is only `minLength` long.
- A scroll view has no intrinsic size along its scrolling axis. Nested in a stack, an `HScroll` needs its width from outside and a `VScroll` its height: use `.fill` alignment in the enclosing stack, as above, or `frame`.
- `showsIndicators` controls the scroller of the scrolling direction, through `hasHorizontalScroller` or `hasVerticalScroller`.
- The scroll view draws no background, so what is behind it shows through; use `.drawsBackground(true)` and `.backgroundColor(_:)` to give it one. `automaticallyAdjustsContentInsets` is `false`, so the content starts at the scroll view's edges; mount it with `safeArea` to keep the whole scroll view inside the safe area.

Modifiers return the same scroll view as `Self`:

| Type | Modifiers |
| --- | --- |
| `HScroll`, `VScroll` | `showsIndicators`, `alignment`, `spacing`, `padding(_ length:)`, `padding(_ edges:_ length:)` |
| `NSScrollView` | `horizontalScrollElasticity`, `verticalScrollElasticity`, `scrollerStyle`, `autohidesScrollers`, `drawsBackground`, `backgroundColor` |

`alignment`, `spacing` and `padding` configure the embedded stack. Padding lies inside the scrolled content, so it scrolls with the elements and counts toward the scrollable length. For any other stack setting, such as `distribution`, the other `padding` forms or a stack `background`, use the read-only `stack` property:

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background(.controlBackgroundColor) }
```

Reusable lists are out of scope; use `NSTableView` or `NSCollectionView` for long, reusable content.

## Roadmap

Available today: `addContent` mounting with safe-area edges, `NSViewBuilder` with `HStack` and `VStack`, `padding` for stacks, `frame` size constraints, `background` and `overlay`, `Spacer` with layout priority modifiers, `HScroll` / `VScroll`, and property modifiers for `NSView`, `NSControl`, `NSTextField`, `NSButton`, `NSTextView`, `NSSlider`, `NSSwitch` and `NSImageView`.

Not included: target–action helpers and data binding, and an example app.

The API may change before 1.0.

## Known limitations

- On a plain `NSStackView`, `padding` only sets `edgeInsets`, and AppKit lets an element that is too large take over the padding across the stack's axis. `HStack` and `VStack` keep it fixed, and they are also the only stacks with the `fill` alignment.
- `background(_:)` adds a subview to the stack, the `NSBox` that draws the color.
- There is no `ZStack`; compose with `background` and `overlay`.
- The package declares a minimum of macOS 11 and its APIs are reviewed for macOS 11 availability, but it has only been built and tested on recent macOS versions.

## Development

The tests exercise AppKit and run on macOS:

```sh
scripts/test-macos.sh
```

The script runs `swift test` with Xcode's toolchain and forwards any extra arguments, such as `--filter StackTests`. Set `DEVELOPER_DIR` to use a different Xcode.

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
