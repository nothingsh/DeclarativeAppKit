# DeclarativeAppKit

[English](README.md) | **简体中文** | [繁體中文](README.zh-Hant.md)

一个轻量的 AppKit 声明式布局库，基于原生 `NSView` 与 Auto Layout 构建，不依赖任何第三方库。

它不引入自定义渲染层，也不维护平行的视图层级。你拿到的始终是真正的 `NSView` 或其子类，因此可以与现有 AppKit 代码自由混用。

UIKit 版本见兄弟包 [DeclarativeUIKit](https://github.com/nothingsh/DeclarativeUIKit)。两者使用同一套词汇，互不依赖。

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    NSTextField(labelWithString: "Ada Lovelace")
        .font(.preferredFont(forTextStyle: .headline))
    NSTextField(labelWithString: "Mathematician")
        .font(.preferredFont(forTextStyle: .subheadline))
        .textColor(.secondaryLabelColor)
}
```

## 目录

- [环境要求](#环境要求)
- [安装](#安装)
- [用法](#用法)
  - [`addContent(_:)`](#addcontent_)
  - [Stack](#stack)
  - [内容闭包](#内容闭包)
  - [属性 modifier](#属性-modifier)
  - [Padding](#padding)
  - [Frame](#frame)
  - [Background 与 overlay](#background-与-overlay)
  - [Spacer 与布局优先级](#spacer-与布局优先级)
  - [滚动视图](#滚动视图)
- [路线图](#路线图)
- [已知限制](#已知限制)
- [开发](#开发)
- [许可证](#许可证)

## 环境要求

- macOS 11.0+
- Swift 5.9+
- 无外部依赖，只使用系统 AppKit

## 安装

使用 Swift Package Manager。在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeAppKit.git", from: "0.1.0")
]
```

或在 Xcode 中选择 File → Add Package Dependencies，输入 `https://github.com/nothingsh/DeclarativeAppKit`。

## 用法

### `addContent(_:)`

把视图挂载到父视图中，使其填满父视图，或在你指定的边上填满父视图的安全区。

```swift
@discardableResult
func addContent<Content: NSView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(NSTextField(labelWithString: "Title"))   // 返回这个 NSTextField
view.addContent(customView)                                          // 返回值可以忽略
view.addContent(page, safeArea: .all)                                // 保持在安全区内
```

- 默认把内容的四条边固定到父视图的四条边，使其填满父视图的 bounds，并忽略安全区。
- `safeArea` 中列出的边改为固定到父视图的 `safeAreaLayoutGuide`。在这些边上，内容（包括它绘制的背景）都保持在安全区内，并随安全区的变化而调整。只列出部分边，其余的边就可以延伸到父视图边缘：`safeArea: .top` 让内容避开全尺寸内容窗口的标题栏，同时仍延伸到另外三条边。
- 使用 `leadingAnchor` 与 `trailingAnchor`，因此布局会在从右到左的语言中自动镜像。`LayoutEdges` 与 `padding` 使用的是同一个 option set。
- 返回传入的同一个实例，并保留其具体类型。
- 不改动内容自身的尺寸约束。

一个视图应当只挂载一次。若内容已有 superview 时再次调用，会通过 `NSLog` 打印一条提示，把内容从当前父视图移除（这会删掉它与旧层级之间的约束），然后重新挂载。约束不会累积，但内容会移到子视图顺序的最前面。

### Stack

`HStack` 与 `VStack` 沿一条轴排列视图。两者都是 `NSStackView` 的子类，所有原生 stack API 仍然可用。

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

- `alignment` 是交叉轴上的对齐。`VStack` 接受 `HorizontalAlignment`：`leading`、`center`、`trailing`、`fill`。`HStack` 接受 `VerticalAlignment`：`top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline`、`fill`。基线相关的取值使用 AppKit 自己的基线对齐。
- `fill` 在 SwiftUI 中没有对应项，它把每个元素沿交叉轴拉伸。`NSStackView` 本身没有这种对齐；它由 `HStack` 与 `VStack` 补上。
- `spacing` 默认为 `0`，因此你看到的间距就是你写下的间距。这与 SwiftUI 不同（其默认间距随上下文而定），也与普通的 `NSStackView` 不同（其默认值为 `8`）。
- `distribution` 为 `.fill`，通过 modifier 配置，而不是初始化参数。普通的 `NSStackView` 默认为 `.gravityAreas`。
- 构造 stack 不会把它挂载到任何地方，元素保持声明顺序。
- 隐藏的元素不占空间，与 `NSStackView` 一致。
- 两种 stack 都是翻转的，因此它们自己的坐标系从左上角开始。

构造并挂载一步完成：

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` 与 `addVStack` 接受与初始化方法相同的参数，外加 `safeArea`，通过 `addContent` 挂载新的 stack 并返回它。与 `addContent` 一样，除非你指定安全区的边，否则 stack 会填满父视图：

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

Stack 的 modifier 返回该 stack，因此可以在构造后或挂载后继续配置：

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` 与 `distribution(_:)` 适用于任何 `NSStackView`。`alignment(_:)` 按方向分别定义，因此在 `HStack` 上接受 `VerticalAlignment`，在 `VStack` 上接受 `HorizontalAlignment`。

### 内容闭包

Stack 的内容用 `@NSViewBuilder` 书写，它按声明顺序收集视图，接受以下形式：

| 形式 | 示例 |
| --- | --- |
| 一个视图 | `NSButton()` |
| 一个可选视图 | `subtitle`，其中 `subtitle: NSTextField?`，`nil` 不产生任何元素 |
| 一个视图数组 | `rows`，其中 `rows: [NSView]` |
| `if` 与 `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(macOS 14, *) { modernView }` |
| 什么都不写 | `VStack {}` |

不是 `NSView` 的表达式会导致编译失败，而不会被悄悄丢弃。

一个 `NSView` 只能属于一个父视图，因此同一个实例不能在同一个内容闭包中出现两次。这属于编程错误：它会带着说明信息触发 trap，而不是悄悄合并成一个元素。

### 属性 modifier

属性 modifier 设置接收者的某个 AppKit 属性，并以 `Self` 返回同一个实例，因此链式调用中具体类型得以保留，通用 modifier 之后仍可以继续使用特定类型的 modifier。同一属性被设置两次时，以最后一次为准。

```swift
let title = NSTextField(wrappingLabelWithString: "Title")
    .font(.preferredFont(forTextStyle: .title2))
    .maximumNumberOfLines(0)
    .accessibilityIdentifier("title")

title.stringValue("Updated")   // 之后的更新通过同一个引用进行
```

每个 modifier 的名称和类型都与它设置的 AppKit 属性相同。

| 类型 | Modifier |
| --- | --- |
| `NSView` 及任何子类 | `configure`、`alphaValue`、`isHidden`、`toolTip`、`clipsToBounds`、`accessibilityLabel`、`accessibilityIdentifier` |
| `NSControl` 及任何子类 | `isEnabled`、`isHighlighted`、`controlSize`、`font`、`alignment`、`lineBreakMode` |
| `NSTextField` | `stringValue`、`attributedStringValue`、`placeholderString`、`textColor`、`maximumNumberOfLines`、`isEditable`、`isSelectable` |
| `NSButton` | `title`、`attributedTitle`、`image`、`alternateTitle`、`alternateImage`、`imagePosition`、`bezelStyle`、`buttonType`、`state`、`contentTintColor` |
| `NSTextView` | `string`、`font`、`textColor`、`alignment`、`isEditable`、`isSelectable` |
| `NSSlider` | `doubleValue`、`minValue`、`maxValue`、`trackFillColor` |
| `NSSwitch` | `state` |
| `NSImageView` | `image`、`imageScaling`、`imageAlignment`、`contentTintColor` |

它们并未穷尽 AppKit 的全部属性；其他属性请使用 `configure`，它会把带有具体类型的视图交给你：

```swift
let avatar = NSImageView()
    .image(photo)
    .imageScaling(.scaleProportionallyUpOrDown)
    .configure {
        $0.wantsLayer = true
        $0.layer?.cornerRadius = 24
    }
```

- Label 就是 `NSTextField`。用 AppKit 的 `NSTextField(labelWithString:)` 或 `NSTextField(wrappingLabelWithString:)` 创建；所有 `NSTextField` 与 `NSControl` 的 modifier 都适用于它。本库不新增 label 类型。
- `maximumNumberOfLines(0)` 让可换行的 label 使用所需的任意行数；在 Auto Layout 下，它的高度随可用宽度变化。
- `accessibilityLabel` 与 `accessibilityIdentifier` 调用的是 AppKit 的 `setAccessibilityLabel(_:)` 与 `setAccessibilityIdentifier(_:)`。

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

- 对于有开关状态的按钮类型，`NSButton` 在关闭状态显示 `title` 与 `image`，在开启状态显示 `alternateTitle` 与 `alternateImage`。`buttonType` 调用的是 `setButtonType(_:)`。
- 事件使用 AppKit 自己的 target–action：设置 `play.target` 与 `play.action`。这些 modifier 不添加 target，也不添加闭包回调。
- 用 `state` 或 `doubleValue` 设置值不是用户事件，不会发送 action，这与 AppKit 属性的行为一致。
- `NSSlider` 会把 `doubleValue` 限制在当前范围内，因此请先设置 `minValue` 与 `maxValue`，再设置 `doubleValue`。
- `NSTextView` 自身不会滚动。需要可滚动的文本视图时，从 AppKit 的 `NSTextView.scrollableTextView()` 开始，再配置它的 `documentView`。
- 代理与编辑行为保持 AppKit 原样。这些 modifier 不设置代理，也没有双向绑定或输入校验。

### Padding

Padding 是 stack 的 modifier。它设置 stack 的 `edgeInsets`，然后返回同一个 stack。

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
stack.padding(horizontal: 16, vertical: 12)                   // 每条轴一个值
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // 每条边各不相同
stack.padding(.top, 24, others: 8)                            // 一条边特殊，其余相同
```

- Padding 计入 stack 的尺寸：内容为 20 × 30 的 stack，加上 `.padding(10)` 后为 40 × 50。
- 它的行为类似属性。`padding(_:_:)` 只改变你指定的边，其余的边保持不变，因此 `.padding(.horizontal, 16).padding(.vertical, 12)` 会设置全部四条边。其他形式都在一次调用中设置全部四条边。后一次调用会替换之前的值，而不是叠加。
- `LayoutEdges` 是由 `top`、`leading`、`bottom`、`trailing` 以及 `horizontal`、`vertical`、`all` 组成的 option set。水平方向的边是 `leading` 与 `trailing`，因此在从右到左的语言中会镜像。
- 在 `HStack` 或 `VStack` 上，padding 在四条边上都是固定距离：过大的元素会被压缩，而不会侵入 padding；`center` 对齐是在留白之后的两条边之间居中。普通的 `NSStackView` 保持 AppKit 自己的行为，见[已知限制](#已知限制)。
- Padding 从不包含安全区。要让内容保持在安全区内，请用 `safeArea` 挂载；参见 [`addContent(_:)`](#addcontent_)。
- 要给单个视图加 padding，把它放进 stack：`VStack { label }.padding(16)`。

### Frame

`frame` 在视图自身上添加尺寸约束，并以 `Self` 返回它，因此链式调用保留具体类型。与 SwiftUI 一样，它有固定尺寸和尺寸范围两种形式。

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

- 它把 `translatesAutoresizingMaskIntoConstraints` 设为 `false`，并使用 required 的 `widthAnchor` / `heightAnchor` 约束：固定长度用 `==`，最小值用 `>=`，最大值用 `<=`。
- 每次调用会重新定义它提到的轴，另一条轴保持不变。先调用 `frame(width: 100)` 再调用 `frame(width: 120)`，更新的是同一条约束。固定宽度会移除之前的最小或最大宽度，范围会移除之前的固定宽度，因此在两者之间切换不会冲突。在范围形式中，只指定一条轴的一个边界会移除另一个：在 `frame(maxWidth: 200)` 之后调用 `frame(minWidth: 40)`，只留下最小值。
- `.infinity` 可以作为最大值，表示没有上限；它不添加任何约束。
- `frame(aspectRatio:)` 让宽度等于比例乘以高度，与 SwiftUI 一致（`16 / 9` 表示宽大于高）。把它与固定宽度或固定高度搭配，可以推导出另一个长度；如果两者都固定，就会冲突。重复调用会替换比例，传入 `nil` 则移除它。
- 只有 `frame` 创建的约束会被更新或移除。你自己添加的尺寸约束不会被改动。
- 负数或非有限的固定长度或最小值、负数或 NaN 的最大值、最小值大于最大值，或者不是有限正数的宽高比，都属于编程错误，会带着说明信息触发 trap。

### Background 与 overlay

装饰会作为被装饰视图的子视图添加，并用约束固定。所有形式都以 `Self` 返回同一个视图。不会插入容器视图，也没有 `ZStack`。

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

- `background(_:)` 是 stack 的 modifier。`NSView` 自身没有背景色，因此它在 stack 内容的后面放一个用该颜色填充的无边框 `NSBox`。像 `.controlBackgroundColor` 这样的动态颜色会跟随浅色与深色外观。自己会绘制背景的控件（例如 `NSTextField` 与 `NSScrollView`）有各自的 AppKit 属性。
- `background { ... }` 同样是 stack 的 modifier。该视图位于 stack 内容的后面，在默认的 `.fill` 下覆盖整个 stack（包括 padding）。要在单个视图后面放背景，把该视图放进 stack：`VStack { label }.padding(8).background { badgeShape }`。
- `overlay` 适用于任何视图，位于该视图现有子视图的前面，在默认的 `.fill` 下覆盖整个视图。之后添加的子视图（例如之后追加的 arranged subview）会位于它的前面。
- 被装饰视图的内容决定其尺寸。在 `.fill` 下，装饰视图的 hugging 与 compression resistance 被设为 `.fittingSizeCompression`，因此一张大图不会把视图撑大。但如果装饰视图自己的子视图要求最小尺寸（例如一组 label 组成的 stack），仍然可能撑大。
- `LayoutAlignment` 取值为 `fill`、`center`、`top`、`bottom`、`leading`、`trailing`、`topLeading`、`topTrailing`、`bottomLeading` 或 `bottomTrailing`。`fill` 把装饰拉伸覆盖整个视图。其他取值保留装饰自身的尺寸，并把它放在对应位置。`leading` 与 `trailing` 在从右到左的语言中会镜像。
- 装饰会叠加，与 SwiftUI 一致：后添加的背景位于更后面，后添加的 `overlay` 位于更前面。
- 装饰视图应当只添加一次。若它已有 superview，会打印提示，先将其移除（同时删掉其已有约束），再重新添加。
- 鼠标事件遵循 AppKit 的命中测试。背景位于内容后面，因此从不遮挡控件。会处理鼠标事件的 overlay 会接收其 bounds 内的事件，并遮挡其后的内容。

### Spacer 与布局优先级

`Spacer` 是一个空视图，它沿所在 stack 的轴占据剩余长度。布局优先级通过两个 modifier 设置，适用于任何视图，并以 `Self` 返回同一个视图。

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

- Spacer 会先于有内容的视图让步：在 stack 的轴上，它的 hugging 优先级为 `.fittingSizeCompression`，因此它吸收多余的空间，其他视图保持固有尺寸。在交叉轴上它没有自己的尺寸，除非 stack 的对齐是 `fill`，否则不占长度。
- 同一个 stack 中的多个 spacer 平分多余的空间。
- `minLength` 是 required 的最小值。当 stack 放不下时，其他视图按各自的 compression resistance 收缩；用 `compressionResistancePriority` 调低某个视图的优先级，可以决定哪个视图先让步。如果 stack 中的固定尺寸根本放不下，required 约束就会冲突，AppKit 会打破其中一条，这与任何 Auto Layout 布局一样。
- 在无界的轴上（例如滚动视图的滚动轴）没有剩余长度，因此 spacer 的长度只有 `minLength`。
- 轴是在 spacer 被添加到 `NSStackView` 时读取的，无论是通过内容闭包还是通过 `addArrangedSubview`。之后修改该 stack 的 `orientation` 不会被跟随。不在 `NSStackView` 中的 spacer 不起作用，把它添加到非 stack 视图时会打印提示。
- 需要固定间隔时，请对空视图使用 `frame`，或使用 stack 的 `spacing`。
- 这些优先级是 AppKit 的 content hugging 与 compression resistance，而不是 SwiftUI 的 `layoutPriority`：它们只在原本会按固有内容尺寸决定大小的视图之间起作用。

### 滚动视图

`HScroll` 与 `VScroll` 是可滚动的 stack：你列出的元素由内置的 `HStack` 或 `VStack` 排列，因此不必在里面再写一个 stack。两者都是 `NSScrollView` 的子类，所有原生滚动视图 API 仍然可用。

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

- `alignment`、`spacing` 与内容闭包的含义和 `HStack`、`VStack` 相同，默认值也相同。`addHScroll` 与 `addVScroll` 接受相同的参数，外加 `safeArea`，通过 `addContent` 挂载并返回滚动视图。
- 内置 stack 是滚动视图的 `documentView`，因此由元素决定可滚动的长度。在另一条轴上，stack 与可见区域一致：`VScroll` 的 stack 与它等宽，`HScroll` 的 stack 与它等高，`alignment` 决定元素在这条轴上的位置。当滚动视图尺寸变化或某个元素变化（例如 label 换行变成更多行）时，可滚动的长度会随之更新。
- 内容从顶部开始。比滚动视图短的内容保持自身长度，停在顶部，不会被拉伸填满。
- 滚动轴是无界的，因此滚动视图中的 `Spacer` 长度只有 `minLength`。
- 滚动视图在滚动轴上没有固有尺寸。嵌套在 stack 中时，`HScroll` 的宽度需要由外部给出，`VScroll` 则是高度：请像上面那样在外层 stack 中使用 `.fill` 对齐，或使用 `frame`。
- `showsIndicators` 控制滚动方向上的滚动条，对应 `hasHorizontalScroller` 或 `hasVerticalScroller`。
- 滚动视图不绘制背景，因此它后面的内容会透出来；用 `.drawsBackground(true)` 与 `.backgroundColor(_:)` 可以给它一个背景。`automaticallyAdjustsContentInsets` 为 `false`，因此内容从滚动视图的边缘开始；用 `safeArea` 挂载可以让整个滚动视图保持在安全区内。

Modifier 以 `Self` 返回同一个滚动视图：

| 类型 | Modifier |
| --- | --- |
| `HScroll`、`VScroll` | `showsIndicators`、`alignment`、`spacing`、`padding(_ length:)`、`padding(_ edges:_ length:)` |
| `NSScrollView` | `horizontalScrollElasticity`、`verticalScrollElasticity`、`scrollerStyle`、`autohidesScrollers`、`drawsBackground`、`backgroundColor` |

`alignment`、`spacing` 与 `padding` 配置的是内置 stack。Padding 位于滚动内容之内，因此会随元素一起滚动，并计入可滚动的长度。其他 stack 设置，例如 `distribution`、其他形式的 `padding` 或 stack 的 `background`，请使用只读的 `stack` 属性：

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background(.controlBackgroundColor) }
```

可复用列表不在本库范围内；长的、需要复用的内容请使用 `NSTableView` 或 `NSCollectionView`。

## 路线图

目前已提供：带安全区边的 `addContent` 挂载，`NSViewBuilder` 与 `HStack`、`VStack`，stack 的 `padding`，`frame` 尺寸约束，`background` 与 `overlay`，`Spacer` 与布局优先级 modifier，`HScroll` / `VScroll`，以及 `NSView`、`NSControl`、`NSTextField`、`NSButton`、`NSTextView`、`NSSlider`、`NSSwitch` 与 `NSImageView` 的属性 modifier。

尚未包含：target–action 辅助与数据绑定，以及示例应用。

1.0 之前 API 可能会发生变化。

## 已知限制

- 在普通的 `NSStackView` 上，`padding` 只设置 `edgeInsets`，AppKit 会让过大的元素占用交叉轴方向的 padding。`HStack` 与 `VStack` 会保持它固定，并且只有它们支持 `fill` 对齐。
- `background(_:)` 会给 stack 增加一个子视图，即绘制该颜色的 `NSBox`。
- 没有 `ZStack`；请用 `background` 与 `overlay` 组合。
- 本 package 声明的最低版本是 macOS 11，API 都按 macOS 11 的可用性审查过，但只在较新的 macOS 版本上构建和测试过。

## 开发

测试会调用 AppKit，在 macOS 上运行：

```sh
scripts/test-macos.sh
```

脚本使用 Xcode 的工具链运行 `swift test`，并转发额外的参数，例如 `--filter StackTests`。设置 `DEVELOPER_DIR` 可以换用另一个 Xcode。

## 许可证

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
