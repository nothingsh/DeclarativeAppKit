# DeclarativeAppKit

[English](README.md) | [简体中文](README.zh-Hans.md) | **繁體中文**

一個輕量的 AppKit 宣告式版面配置函式庫，以原生 `NSView` 與 Auto Layout 建構，不依賴任何第三方函式庫。

它不引入自訂的繪製層，也不維護平行的視圖階層。你拿到的永遠是真正的 `NSView` 或其子類別，因此能與既有的 AppKit 程式碼自由混用。

UIKit 版本請見姊妹套件 [DeclarativeUIKit](https://github.com/nothingsh/DeclarativeUIKit)。兩者使用同一套詞彙，互不依賴。

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    NSTextField(labelWithString: "Ada Lovelace")
        .font(.preferredFont(forTextStyle: .headline))
    NSTextField(labelWithString: "Mathematician")
        .font(.preferredFont(forTextStyle: .subheadline))
        .textColor(.secondaryLabelColor)
}
```

## 目錄

- [系統需求](#系統需求)
- [安裝](#安裝)
- [用法](#用法)
  - [`addContent(_:)`](#addcontent_)
  - [Stack](#stack)
  - [內容閉包](#內容閉包)
  - [屬性 modifier](#屬性-modifier)
  - [Padding](#padding)
  - [Frame](#frame)
  - [Background 與 overlay](#background-與-overlay)
  - [Spacer 與版面優先權](#spacer-與版面優先權)
  - [捲動視圖](#捲動視圖)
- [發展藍圖](#發展藍圖)
- [已知限制](#已知限制)
- [開發](#開發)
- [授權條款](#授權條款)

## 系統需求

- macOS 11.0+
- Swift 5.9+
- 無外部依賴，只使用系統 AppKit

## 安裝

使用 Swift Package Manager。在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeAppKit.git", from: "0.1.0")
]
```

或在 Xcode 中選擇 File → Add Package Dependencies，輸入 `https://github.com/nothingsh/DeclarativeAppKit`。

## 用法

### `addContent(_:)`

把視圖掛載到父視圖中，使其填滿父視圖，或在你指定的邊上填滿父視圖的安全區域。

```swift
@discardableResult
func addContent<Content: NSView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(NSTextField(labelWithString: "Title"))   // 回傳這個 NSTextField
view.addContent(customView)                                          // 回傳值可以忽略
view.addContent(page, safeArea: .all)                                // 保持在安全區域內
```

- 預設把內容的四條邊固定到父視圖的四條邊，使其填滿父視圖的 bounds，並忽略安全區域。
- `safeArea` 中列出的邊改為固定到父視圖的 `safeAreaLayoutGuide`。在這些邊上，內容（包括它繪製的背景）都保持在安全區域內，並隨安全區域的變化而調整。只列出部分邊，其餘的邊就能延伸到父視圖邊緣：`safeArea: .top` 讓內容避開全尺寸內容視窗的標題列，同時仍延伸到另外三條邊。
- 使用 `leadingAnchor` 與 `trailingAnchor`，因此版面會在由右至左的語言中自動鏡像。`LayoutEdges` 與 `padding` 使用的是同一個 option set。
- 回傳傳入的同一個實例，並保留其具體型別。
- 不更動內容本身的尺寸約束。

一個視圖應當只掛載一次。若內容已有 superview 時再次呼叫，會透過 `NSLog` 輸出一則提示，把內容從目前的父視圖移除（這會刪除它與舊階層之間的約束），然後重新掛載。約束不會累積，但內容會移到子視圖順序的最前面。

### Stack

`HStack` 與 `VStack` 沿一條軸排列視圖。兩者都是 `NSStackView` 的子類別，所有原生 stack API 仍然可用。

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

- `alignment` 是交叉軸上的對齊。`VStack` 接受 `HorizontalAlignment`：`leading`、`center`、`trailing`、`fill`。`HStack` 接受 `VerticalAlignment`：`top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline`、`fill`。基線相關的值使用 AppKit 自己的基線對齊。
- `fill` 在 SwiftUI 中沒有對應項，它把每個元素沿交叉軸延展。`NSStackView` 本身沒有這種對齊；它由 `HStack` 與 `VStack` 補上。
- `spacing` 預設為 `0`，因此你看到的間距就是你寫下的間距。這與 SwiftUI 不同（其預設間距隨情境而定），也與一般的 `NSStackView` 不同（其預設值為 `8`）。
- `distribution` 為 `.fill`，透過 modifier 設定，而不是初始化參數。一般的 `NSStackView` 預設為 `.gravityAreas`。
- 建構 stack 不會把它掛載到任何地方，元素保持宣告順序。
- 隱藏的元素不佔空間，與 `NSStackView` 一致。
- 兩種 stack 都是翻轉的，因此它們自己的座標系從左上角開始。

建構並掛載一步完成：

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` 與 `addVStack` 接受與初始化方法相同的參數，外加 `safeArea`，透過 `addContent` 掛載新的 stack 並回傳它。與 `addContent` 一樣，除非你指定安全區域的邊，否則 stack 會填滿父視圖：

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

Stack 的 modifier 回傳該 stack，因此可以在建構後或掛載後繼續設定：

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` 與 `distribution(_:)` 適用於任何 `NSStackView`。`alignment(_:)` 依方向分別定義，因此在 `HStack` 上接受 `VerticalAlignment`，在 `VStack` 上接受 `HorizontalAlignment`。

### 內容閉包

Stack 的內容以 `@NSViewBuilder` 撰寫，它依宣告順序收集視圖，接受以下形式：

| 形式 | 範例 |
| --- | --- |
| 一個視圖 | `NSButton()` |
| 一個可選視圖 | `subtitle`，其中 `subtitle: NSTextField?`，`nil` 不產生任何元素 |
| 一個視圖陣列 | `rows`，其中 `rows: [NSView]` |
| `if` 與 `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(macOS 14, *) { modernView }` |
| 什麼都不寫 | `VStack {}` |

不是 `NSView` 的運算式會導致編譯失敗，而不會被悄悄丟棄。

一個 `NSView` 只能屬於一個父視圖，因此同一個實例不能在同一個內容閉包中出現兩次。這屬於程式錯誤：它會帶著說明訊息觸發 trap，而不是悄悄合併成一個元素。

### 屬性 modifier

屬性 modifier 設定接收者的某個 AppKit 屬性，並以 `Self` 回傳同一個實例，因此鏈式呼叫中具體型別得以保留，通用 modifier 之後仍能繼續使用特定型別的 modifier。同一屬性被設定兩次時，以最後一次為準。

```swift
let title = NSTextField(wrappingLabelWithString: "Title")
    .font(.preferredFont(forTextStyle: .title2))
    .maximumNumberOfLines(0)
    .accessibilityIdentifier("title")

title.stringValue("Updated")   // 之後的更新透過同一個參照進行
```

每個 modifier 的名稱與型別都與它設定的 AppKit 屬性相同。

| 型別 | Modifier |
| --- | --- |
| `NSView` 及任何子類別 | `configure`、`alphaValue`、`isHidden`、`toolTip`、`clipsToBounds`、`accessibilityLabel`、`accessibilityIdentifier` |
| `NSControl` 及任何子類別 | `isEnabled`、`isHighlighted`、`controlSize`、`font`、`alignment`、`lineBreakMode` |
| `NSTextField` | `stringValue`、`attributedStringValue`、`placeholderString`、`textColor`、`maximumNumberOfLines`、`isEditable`、`isSelectable` |
| `NSButton` | `title`、`attributedTitle`、`image`、`alternateTitle`、`alternateImage`、`imagePosition`、`bezelStyle`、`buttonType`、`state`、`contentTintColor` |
| `NSTextView` | `string`、`font`、`textColor`、`alignment`、`isEditable`、`isSelectable` |
| `NSSlider` | `doubleValue`、`minValue`、`maxValue`、`trackFillColor` |
| `NSSwitch` | `state` |
| `NSImageView` | `image`、`imageScaling`、`imageAlignment`、`contentTintColor` |

它們並未窮盡 AppKit 的全部屬性；其他屬性請使用 `configure`，它會把帶有具體型別的視圖交給你：

```swift
let avatar = NSImageView()
    .image(photo)
    .imageScaling(.scaleProportionallyUpOrDown)
    .configure {
        $0.wantsLayer = true
        $0.layer?.cornerRadius = 24
    }
```

- Label 就是 `NSTextField`。以 AppKit 的 `NSTextField(labelWithString:)` 或 `NSTextField(wrappingLabelWithString:)` 建立；所有 `NSTextField` 與 `NSControl` 的 modifier 都適用於它。本函式庫不新增 label 型別。
- `maximumNumberOfLines(0)` 讓可換行的 label 使用所需的任意行數；在 Auto Layout 下，它的高度隨可用寬度變化。
- `accessibilityLabel` 與 `accessibilityIdentifier` 呼叫的是 AppKit 的 `setAccessibilityLabel(_:)` 與 `setAccessibilityIdentifier(_:)`。

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

- 對於有開關狀態的按鈕類型，`NSButton` 在關閉狀態顯示 `title` 與 `image`，在開啟狀態顯示 `alternateTitle` 與 `alternateImage`。`buttonType` 呼叫的是 `setButtonType(_:)`。
- 事件使用 AppKit 自己的 target–action：設定 `play.target` 與 `play.action`。這些 modifier 不加入 target，也不加入閉包回呼。
- 以 `state` 或 `doubleValue` 設定值不是使用者事件，不會送出 action，這與 AppKit 屬性的行為一致。
- `NSSlider` 會把 `doubleValue` 限制在目前的範圍內，因此請先設定 `minValue` 與 `maxValue`，再設定 `doubleValue`。
- `NSTextView` 本身不會捲動。需要可捲動的文字視圖時，從 AppKit 的 `NSTextView.scrollableTextView()` 開始，再設定它的 `documentView`。
- 委派與編輯行為保持 AppKit 原樣。這些 modifier 不設定委派，也沒有雙向繫結或輸入驗證。

### Padding

Padding 是 stack 的 modifier。它設定 stack 的 `edgeInsets`，然後回傳同一個 stack。

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
stack.padding(horizontal: 16, vertical: 12)                   // 每條軸一個值
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // 每條邊各不相同
stack.padding(.top, 24, others: 8)                            // 一條邊特殊，其餘相同
```

- Padding 計入 stack 的尺寸：內容為 20 × 30 的 stack，加上 `.padding(10)` 後為 40 × 50。
- 它的行為類似屬性。`padding(_:_:)` 只改變你指定的邊，其餘的邊保持不變，因此 `.padding(.horizontal, 16).padding(.vertical, 12)` 會設定全部四條邊。其他形式都在一次呼叫中設定全部四條邊。後一次呼叫會取代先前的值，而不是疊加。
- `LayoutEdges` 是由 `top`、`leading`、`bottom`、`trailing` 以及 `horizontal`、`vertical`、`all` 組成的 option set。水平方向的邊是 `leading` 與 `trailing`，因此在由右至左的語言中會鏡像。
- 在 `HStack` 或 `VStack` 上，padding 在四條邊上都是固定距離：過大的元素會被壓縮，而不會侵入 padding；`center` 對齊是在留白之後的兩條邊之間置中。一般的 `NSStackView` 保持 AppKit 自己的行為，請見[已知限制](#已知限制)。
- Padding 從不包含安全區域。要讓內容保持在安全區域內，請以 `safeArea` 掛載；請參閱 [`addContent(_:)`](#addcontent_)。
- 要給單一視圖加上 padding，把它放進 stack：`VStack { label }.padding(16)`。

### Frame

`frame` 在視圖本身加上尺寸約束，並以 `Self` 回傳它，因此鏈式呼叫保留具體型別。與 SwiftUI 一樣，它有固定尺寸與尺寸範圍兩種形式。

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

- 它把 `translatesAutoresizingMaskIntoConstraints` 設為 `false`，並使用 required 的 `widthAnchor` / `heightAnchor` 約束：固定長度用 `==`，最小值用 `>=`，最大值用 `<=`。
- 每次呼叫會重新定義它提到的軸，另一條軸保持不變。先呼叫 `frame(width: 100)` 再呼叫 `frame(width: 120)`，更新的是同一條約束。固定寬度會移除先前的最小或最大寬度，範圍會移除先前的固定寬度，因此在兩者之間切換不會衝突。在範圍形式中，只指定一條軸的一個邊界會移除另一個：在 `frame(maxWidth: 200)` 之後呼叫 `frame(minWidth: 40)`，只留下最小值。
- `.infinity` 可以作為最大值，表示沒有上限；它不加入任何約束。
- `frame(aspectRatio:)` 讓寬度等於比例乘以高度，與 SwiftUI 一致（`16 / 9` 表示寬大於高）。把它與固定寬度或固定高度搭配，即可推導出另一個長度；如果兩者都固定，就會衝突。重複呼叫會取代比例，傳入 `nil` 則移除它。
- 只有 `frame` 建立的約束會被更新或移除。你自己加入的尺寸約束不會被更動。
- 負數或非有限的固定長度或最小值、負數或 NaN 的最大值、最小值大於最大值，或者不是有限正數的長寬比，都屬於程式錯誤，會帶著說明訊息觸發 trap。

### Background 與 overlay

裝飾會作為被裝飾視圖的子視圖加入，並以約束固定。所有形式都以 `Self` 回傳同一個視圖。不會插入容器視圖，也沒有 `ZStack`。

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

- `background(_:)` 是 stack 的 modifier。`NSView` 本身沒有背景色，因此它在 stack 內容的後方放一個以該顏色填滿的無邊框 `NSBox`。像 `.controlBackgroundColor` 這樣的動態顏色會跟隨淺色與深色外觀。自己會繪製背景的控制項（例如 `NSTextField` 與 `NSScrollView`）有各自的 AppKit 屬性。
- `background { ... }` 同樣是 stack 的 modifier。該視圖位於 stack 內容的後方，在預設的 `.fill` 下覆蓋整個 stack（包括 padding）。要在單一視圖後方放背景，把該視圖放進 stack：`VStack { label }.padding(8).background { badgeShape }`。
- `overlay` 適用於任何視圖，位於該視圖現有子視圖的前方，在預設的 `.fill` 下覆蓋整個視圖。之後加入的子視圖（例如之後追加的 arranged subview）會位於它的前方。
- 被裝飾視圖的內容決定其尺寸。在 `.fill` 下，裝飾視圖的 hugging 與 compression resistance 會設為 `.fittingSizeCompression`，因此一張大圖不會把視圖撐大。但若裝飾視圖自己的子視圖要求最小尺寸（例如由數個 label 組成的 stack），仍然可能撐大。
- `LayoutAlignment` 的值為 `fill`、`center`、`top`、`bottom`、`leading`、`trailing`、`topLeading`、`topTrailing`、`bottomLeading` 或 `bottomTrailing`。`fill` 把裝飾延展覆蓋整個視圖。其他值保留裝飾本身的尺寸，並把它放在對應位置。`leading` 與 `trailing` 在由右至左的語言中會鏡像。
- 裝飾會疊加，與 SwiftUI 一致：後加入的背景位於更後方，後加入的 `overlay` 位於更前方。
- 裝飾視圖應當只加入一次。若它已有 superview，會輸出提示，先將其移除（同時刪除其既有約束），再重新加入。
- 滑鼠事件遵循 AppKit 的命中測試。背景位於內容後方，因此從不遮擋控制項。會處理滑鼠事件的 overlay 會接收其 bounds 內的事件，並遮擋其後的內容。

### Spacer 與版面優先權

`Spacer` 是一個空視圖，它沿所在 stack 的軸佔據剩餘長度。版面優先權透過兩個 modifier 設定，適用於任何視圖，並以 `Self` 回傳同一個視圖。

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

- Spacer 會先於有內容的視圖讓步：在 stack 的軸上，它的 hugging 優先權為 `.fittingSizeCompression`，因此它吸收多餘的空間，其他視圖保持固有尺寸。在交叉軸上它沒有自己的尺寸，除非 stack 的對齊是 `fill`，否則不佔長度。
- 同一個 stack 中的多個 spacer 平分多餘的空間。
- `minLength` 是 required 的最小值。當 stack 放不下時，其他視圖依各自的 compression resistance 縮小；用 `compressionResistancePriority` 調低某個視圖的優先權，即可決定哪個視圖先讓步。如果 stack 中的固定尺寸根本放不下，required 約束就會衝突，AppKit 會打破其中一條，這與任何 Auto Layout 版面一樣。
- 在無界的軸上（例如捲動視圖的捲動軸）沒有剩餘長度，因此 spacer 的長度只有 `minLength`。
- 軸是在 spacer 被加入 `NSStackView` 時讀取的，無論是透過內容閉包還是透過 `addArrangedSubview`。之後修改該 stack 的 `orientation` 不會被跟隨。不在 `NSStackView` 中的 spacer 不起作用，把它加入非 stack 視圖時會輸出提示。
- 需要固定間隔時，請對空視圖使用 `frame`，或使用 stack 的 `spacing`。
- 這些優先權是 AppKit 的 content hugging 與 compression resistance，而不是 SwiftUI 的 `layoutPriority`：它們只在原本會依固有內容尺寸決定大小的視圖之間起作用。

### 捲動視圖

`HScroll` 與 `VScroll` 是可捲動的 stack：你列出的元素由內建的 `HStack` 或 `VStack` 排列，因此不必在裡面再寫一個 stack。兩者都是 `NSScrollView` 的子類別，所有原生捲動視圖 API 仍然可用。

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

- `alignment`、`spacing` 與內容閉包的意義和 `HStack`、`VStack` 相同，預設值也相同。`addHScroll` 與 `addVScroll` 接受相同的參數，外加 `safeArea`，透過 `addContent` 掛載並回傳捲動視圖。
- 內建 stack 是捲動視圖的 `documentView`，因此由元素決定可捲動的長度。在另一條軸上，stack 與可見區域一致：`VScroll` 的 stack 與它等寬，`HScroll` 的 stack 與它等高，`alignment` 決定元素在這條軸上的位置。當捲動視圖尺寸改變或某個元素改變（例如 label 換行成更多行）時，可捲動的長度會隨之更新。
- 內容從頂部開始。比捲動視圖短的內容保持本身的長度，停在頂部，不會被延展填滿。
- 捲動軸是無界的，因此捲動視圖中的 `Spacer` 長度只有 `minLength`。
- 捲動視圖在捲動軸上沒有固有尺寸。巢狀放在 stack 中時，`HScroll` 的寬度需要由外部給定，`VScroll` 則是高度：請像上面那樣在外層 stack 中使用 `.fill` 對齊，或使用 `frame`。
- `showsIndicators` 控制捲動方向上的捲軸，對應 `hasHorizontalScroller` 或 `hasVerticalScroller`。
- 捲動視圖不繪製背景，因此它後方的內容會透出來；用 `.drawsBackground(true)` 與 `.backgroundColor(_:)` 即可給它一個背景。`automaticallyAdjustsContentInsets` 為 `false`，因此內容從捲動視圖的邊緣開始；以 `safeArea` 掛載即可讓整個捲動視圖保持在安全區域內。

Modifier 以 `Self` 回傳同一個捲動視圖：

| 型別 | Modifier |
| --- | --- |
| `HScroll`、`VScroll` | `showsIndicators`、`alignment`、`spacing`、`padding(_ length:)`、`padding(_ edges:_ length:)` |
| `NSScrollView` | `horizontalScrollElasticity`、`verticalScrollElasticity`、`scrollerStyle`、`autohidesScrollers`、`drawsBackground`、`backgroundColor` |

`alignment`、`spacing` 與 `padding` 設定的是內建 stack。Padding 位於捲動內容之內，因此會隨元素一起捲動，並計入可捲動的長度。其他 stack 設定，例如 `distribution`、其他形式的 `padding` 或 stack 的 `background`，請使用唯讀的 `stack` 屬性：

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background(.controlBackgroundColor) }
```

可重複使用的清單不在本函式庫範圍內；較長、需要重複使用的內容請使用 `NSTableView` 或 `NSCollectionView`。

## 發展藍圖

目前已提供：帶安全區域邊的 `addContent` 掛載，`NSViewBuilder` 與 `HStack`、`VStack`，stack 的 `padding`，`frame` 尺寸約束，`background` 與 `overlay`，`Spacer` 與版面優先權 modifier，`HScroll` / `VScroll`，以及 `NSView`、`NSControl`、`NSTextField`、`NSButton`、`NSTextView`、`NSSlider`、`NSSwitch` 與 `NSImageView` 的屬性 modifier。

尚未包含：target–action 輔助與資料繫結，以及範例 App。

1.0 之前 API 可能會有所變動。

## 已知限制

- 在一般的 `NSStackView` 上，`padding` 只設定 `edgeInsets`，AppKit 會讓過大的元素佔用交叉軸方向的 padding。`HStack` 與 `VStack` 會保持它固定，而且只有它們支援 `fill` 對齊。
- `background(_:)` 會給 stack 增加一個子視圖，即繪製該顏色的 `NSBox`。
- 沒有 `ZStack`；請以 `background` 與 `overlay` 組合。
- 本 package 宣告的最低版本是 macOS 11，API 皆依 macOS 11 的可用性審查過，但只在較新的 macOS 版本上建置與測試過。

## 開發

測試會呼叫 AppKit，在 macOS 上執行：

```sh
scripts/test-macos.sh
```

指令碼使用 Xcode 的工具鏈執行 `swift test`，並轉送額外的參數，例如 `--filter StackTests`。設定 `DEVELOPER_DIR` 即可換用另一個 Xcode。

## 授權條款

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
