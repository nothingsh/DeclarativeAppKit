# ``DeclarativeAppKit``

Declarative layout for AppKit, built on plain `NSView` and Auto Layout.

## Overview

DeclarativeAppKit builds view hierarchies with result builders and chainable modifiers.
There is no rendering layer of its own: every stack, scroll view and modifier result is a
real `NSView` or subclass, laid out with Auto Layout, so it mixes freely with existing
AppKit code.

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    NSTextField(labelWithString: "Ada Lovelace")
        .font(.preferredFont(forTextStyle: .headline))
    NSTextField(labelWithString: "Mathematician")
        .font(.preferredFont(forTextStyle: .subheadline))
        .textColor(.secondaryLabelColor)
}
.padding(16)
```

## Topics

### Stacks

- ``VStack``
- ``HStack``
- ``Spacer``
- ``HorizontalAlignment``
- ``VerticalAlignment``

### Scroll views

- ``VScroll``
- ``HScroll``

### Building content

- ``NSViewBuilder``
- ``Configurable``

### Layout

- ``LayoutEdges``
- ``LayoutAlignment``
