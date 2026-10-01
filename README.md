# DeclarativeAppKit

**English** | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

A lightweight declarative layout library for AppKit: SwiftUI-style stacks, padding and modifiers on top of plain `NSView` and Auto Layout, with no third-party dependencies.

There is no rendering layer and no parallel view hierarchy. Everything it returns is a real `NSView` or subclass, so it mixes freely with existing AppKit code. For UIKit, see the sibling package [DeclarativeUIKit](https://github.com/nothingsh/DeclarativeUIKit).

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

- [Installation](#installation)
- [Usage](#usage)
  - [Mounting](#mounting)
  - [Stacks](#stacks)
  - [Property modifiers](#property-modifiers)
  - [Padding and frame](#padding-and-frame)
  - [Background and overlay](#background-and-overlay)
  - [Spacer](#spacer)
  - [Scroll views](#scroll-views)
- [Example app](#example-app)
  - [Profile card](#profile-card)
  - [Form](#form)
  - [Scrolling](#scrolling)
- [Known limitations](#known-limitations)
- [Development](#development)
- [License](#license)

## Installation

Requires macOS 11.0+ and Swift 5.9+. Add the package with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeAppKit.git", from: "0.1.0")
]
```

Or in Xcode, choose File → Add Package Dependencies and enter `https://github.com/nothingsh/DeclarativeAppKit`.

## Usage

### Mounting

```swift
view.addContent(page)                          // fills the parent
view.addContent(page, safeArea: .all)          // stays inside the safe area

view.addVStack(spacing: 8, safeArea: .top) {   // builds a stack and mounts it
    title
    body
}
```

`addContent` pins the four edges of a view to its parent and returns the view with its concrete type. The edges named in `safeArea` are pinned to the parent's safe area instead. `addHStack`, `addVStack`, `addHScroll` and `addVScroll` build and mount in one step.

### Stacks

```swift
let column = VStack(alignment: .leading, spacing: 4) {
    name
    role
    if isEditing { field }
    for tag in tags { chip(tag) }
    HStack(spacing: 8) {
        icon
        detail
    }
}
```

- `HStack` and `VStack` are `NSStackView` subclasses, so every native stack API stays available. Constructing one does not mount it.
- `alignment` is the cross axis: `leading`, `center`, `trailing` or `fill` for a `VStack`; `top`, `center`, `bottom`, `firstTextBaseline`, `lastTextBaseline` or `fill` for an `HStack`. `fill` stretches every element.
- `spacing` defaults to `0`, so the gaps you see are the ones you write. `.spacing(_:)`, `.alignment(_:)` and `.distribution(_:)` change a stack afterwards.
- A content closure accepts views, optional views, arrays, `if` / `else`, `switch`, `for` and `if #available`.

### Property modifiers

Each modifier sets the AppKit property of the same name and returns the view as `Self`, so a chain keeps its concrete type.

```swift
let title = NSTextField(wrappingLabelWithString: "Title")
    .font(.preferredFont(forTextStyle: .title2))
    .textColor(.secondaryLabelColor)
    .maximumNumberOfLines(0)

let play = NSButton()
    .buttonType(.toggle)
    .title("Play")
    .alternateTitle("Pause")

let avatar = NSImageView()
    .image(photo)
    .configure { $0.imageFrameStyle = .photo }   // anything without a modifier
```

| Type | Modifiers |
| --- | --- |
| `NSView` | `configure`, `alphaValue`, `isHidden`, `toolTip`, `clipsToBounds`, `accessibilityLabel`, `accessibilityIdentifier` |
| `NSControl` | `isEnabled`, `isHighlighted`, `controlSize`, `font`, `alignment`, `lineBreakMode` |
| `NSTextField` | `stringValue`, `attributedStringValue`, `placeholderString`, `textColor`, `maximumNumberOfLines`, `isEditable`, `isSelectable` |
| `NSButton` | `title`, `attributedTitle`, `image`, `alternateTitle`, `alternateImage`, `imagePosition`, `bezelStyle`, `buttonType`, `state`, `contentTintColor` |
| `NSTextView` | `string`, `font`, `textColor`, `alignment`, `isEditable`, `isSelectable` |
| `NSSlider` | `doubleValue`, `minValue`, `maxValue`, `trackFillColor` |
| `NSSwitch` | `state` |
| `NSImageView` | `image`, `imageScaling`, `imageAlignment`, `contentTintColor` |

A label is an `NSTextField` made with `NSTextField(labelWithString:)` or `NSTextField(wrappingLabelWithString:)`. Events stay AppKit's own target–action and delegates.

### Padding and frame

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)                // every edge
.padding(.horizontal, 24)   // only the named edges

stack.padding(horizontal: 16, vertical: 12)
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)

let avatar = NSImageView().frame(width: 48, height: 48)
let button = NSButton().frame(minWidth: 88)
let banner = NSImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- `padding` is a stack modifier. It is a fixed distance on every edge, counts toward the stack's size and never includes the safe area. To pad a single view, put it in a stack.
- `frame` adds required size constraints to any view. A later call for the same axis replaces the earlier one.

### Background and overlay

```swift
let card = VStack { name }
    .padding(16)
    .background(.quaternaryLabelColor)                     // a color behind the stack

let rounded = VStack { name }
    .padding(16)
    .background { roundedBox }                             // any view behind the stack

let avatar = NSImageView()
    .frame(width: 48, height: 48)
    .overlay(alignment: .bottomTrailing) { statusDot }     // any view in front of a view
```

- A decoration is a subview pinned with constraints; no container view is inserted and there is no `ZStack`. `alignment` is `.fill` by default, or a position such as `.topTrailing`.
- The decorated view's own content decides its size.

### Spacer

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

A `Spacer` takes the remaining length along the axis of its stack, and several spacers share it equally. `contentHuggingPriority(_:for:)` and `compressionResistancePriority(_:for:)` choose which of the other views grows or shrinks first.

### Scroll views

```swift
view.addVScroll(alignment: .fill, spacing: 12) {
    title
    HScroll(spacing: 8, showsIndicators: false) {
        for name in tagNames { chip(name) }
    }
    body
}
.padding(16)
```

- `HScroll` and `VScroll` are `NSScrollView` subclasses that arrange their elements with an embedded stack, available as `stack`. The elements decide the scrollable length; on the other axis the content matches the scroll view.
- Nested in a stack, an `HScroll` needs its width from outside and a `VScroll` its height: use `.fill` alignment, as above, or `frame`.
- Scrolling in the other direction is passed on, so the page above still scrolls vertically while the pointer is over the `HScroll`.
- A scroll view draws no background unless you set `.drawsBackground(true)`.

## Example app

`Example/Example.xcodeproj` is a small macOS app that uses the library as a local package. Open it in Xcode, choose the `Example` scheme and run. Its window has one tab per screen, and the snippets below are trimmed from the three screens.

### Profile card

The code has the same shape as the screen. The status badge is attached to the avatar with `overlay`, with no wrapper view or `ZStack`. `bio` and `status` are ordinary properties: the buttons change them directly, and Auto Layout resizes the card. Nothing is rebuilt.

<table>
<tr>
<td>

```swift
VStack(alignment: .leading, spacing: 12) {
    HStack(spacing: 12) {
        NSImageView()
            .image(avatar)
            .contentTintColor(.systemIndigo)
            .frame(width: 64, height: 64)
            .overlay(alignment: .bottomTrailing) { status }
        VStack(alignment: .leading, spacing: 2) {
            NSTextField(labelWithString: "Ada Lovelace")
                .font(.preferredFont(forTextStyle: .title2))
            NSTextField(labelWithString: "Mathematician · London")
                .font(.preferredFont(forTextStyle: .subheadline))
                .textColor(.secondaryLabelColor)
        }
        Spacer()
    }
    bio
}
.card()

// Later, from a button's action:
bio.stringValue(Self.longBio)
status.fillColor = .systemGray
```

</td>
<td width="300">
<img src="docs/images/example-profile.png" width="300" alt="Profile card screen">
</td>
</tr>
</table>

A reusable style is just a function over the modifiers. `fill` and `card()` are the app's own helpers, not part of the library:

```swift
func fill(_ color: NSColor, cornerRadius: CGFloat = 0) -> NSBox {
    NSBox().configure {
        $0.boxType = .custom
        $0.borderWidth = 0
        $0.cornerRadius = cornerRadius
        $0.fillColor = color
    }
}

extension NSStackView {
    func card(padding: CGFloat = 16) -> Self {
        self.padding(padding)
            .background { fill(.quaternaryLabelColor, cornerRadius: 12) }
    }
}
```

### Form

The controls are plain `NSTextField`, `NSSwitch` and `NSSlider`, configured with modifiers and kept as properties. Events use AppKit's own target–action and delegates. `Spacer` pushes the switch and the value to the trailing edge.

<table>
<tr>
<td>

```swift
private let newsletter = NSSwitch().state(.on)

private let frequency = NSSlider()
    .minValue(1)
    .maxValue(7)
    .doubleValue(3)

// In viewDidLoad:
frequency.target = self
frequency.action = #selector(frequencyChanged)

VStack(alignment: .fill, spacing: 12) {
    HStack(spacing: 8) {
        NSTextField(labelWithString: "Newsletter")
        Spacer()
        newsletter
    }
    HStack(spacing: 8) {
        NSTextField(labelWithString: "Issues per week")
        Spacer()
        frequencyValue
    }
    frequency
}
.card()
```

</td>
<td width="300">
<img src="docs/images/example-form.png" width="300" alt="Form screen">
</td>
</tr>
</table>

### Scrolling

`HScroll` rows inside a `VScroll`. Content closures accept `for` loops, and small functions that return an `NSView` compose like any other view. Clicking *Add row* appends to a stack kept as a property, and the scrollable length follows.

<table>
<tr>
<td>

```swift
HScroll(spacing: 8, showsIndicators: false) {
    for tag in Self.tags { chip(tag) }
}

HScroll(alignment: .top, spacing: 12) {
    for index in 1...8 { card(index) }
}

rows

private func chip(_ text: String) -> NSView {
    VStack {
        NSTextField(labelWithString: text)
            .font(.preferredFont(forTextStyle: .subheadline))
            .textColor(.systemBlue)
    }
    .padding(horizontal: 12, vertical: 6)
    .background {
        fill(NSColor.systemBlue.withAlphaComponent(0.12),
             cornerRadius: 8)
    }
}
```

</td>
<td width="300">
<img src="docs/images/example-scroll.png" width="300" alt="Scrolling screen">
</td>
</tr>
</table>

The screens adapt as the window is resized. Content closures run once; later changes are made through the views themselves, not through data binding.

The app's deployment target is macOS 12.0, the lowest the current Xcode can build; see [Known limitations](#known-limitations).

## Known limitations

- Only `HStack` and `VStack` have the `fill` alignment and keep padding fixed. On a plain `NSStackView`, AppKit lets an element that is too large take over the padding across the stack's axis.
- `background(_:)` adds a subview to the stack, the `NSBox` that draws the color.
- There are no target–action helpers and no data binding.
- The package declares a minimum of macOS 11 and its APIs are reviewed for macOS 11 availability, but current toolchains build for macOS 12 at the lowest, so nothing has been built or run against macOS 11 itself.

## Development

The tests exercise AppKit and run on macOS:

```sh
scripts/test-macos.sh
```

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
