# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] - 2026-10-14

### Added

- `spacing(_:after:)` on stacks and scroll views, for a different distance after one element.
- `HScroll` and `VScroll` forward every form of `padding`.
- Layer modifiers for any view: `cornerRadius`, `border(color:width:)` and `shadow`.
- Accessibility modifiers: `accessibilityHelp`, `accessibilityRole` and `isAccessibilityElement`.
- `NSTextField` modifier `allowsDefaultTighteningForTruncation`.
- `NSImageView` modifier `symbolConfiguration`.
- Modifiers for `NSSegmentedControl`, `NSStepper` and `NSProgressIndicator`.
- DocC documentation catalog.

### Fixed

- `configure` on a custom view subclass compiles with Swift 6.1 and earlier, where the closure did not receive the subclass type.

## [0.1.0] - 2026-10-01

First release.

[Unreleased]: https://github.com/nothingsh/DeclarativeAppKit/compare/0.2.0...HEAD
[0.2.0]: https://github.com/nothingsh/DeclarativeAppKit/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/nothingsh/DeclarativeAppKit/releases/tag/0.1.0
