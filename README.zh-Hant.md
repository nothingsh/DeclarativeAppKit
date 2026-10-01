# DeclarativeAppKit

[English](README.md) | [简体中文](README.zh-Hans.md) | **繁體中文**

一個輕量的 AppKit 宣告式版面配置函式庫：在原生 `NSView` 與 Auto Layout 之上提供 SwiftUI 風格的 stack、padding 與 modifier，不依賴任何第三方函式庫。

它沒有繪製層，也不維護平行的視圖階層。它回傳的永遠是真正的 `NSView` 或其子類別，因此能與既有的 AppKit 程式碼自由混用。UIKit 版本請見姊妹套件 [DeclarativeUIKit](https://github.com/nothingsh/DeclarativeUIKit)。

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

- [安裝](#安裝)
- [用法](#用法)
  - [掛載](#掛載)
  - [Stack](#stack)
  - [屬性 modifier](#屬性-modifier)
  - [Padding 與 frame](#padding-與-frame)
  - [Background 與 overlay](#background-與-overlay)
  - [Spacer](#spacer)
  - [捲動視圖](#捲動視圖)
- [範例 App](#範例-app)
  - [個人資料卡片](#個人資料卡片)
  - [表單](#表單)
  - [捲動](#捲動)
- [已知限制](#已知限制)
- [開發](#開發)
- [授權條款](#授權條款)

## 安裝

需要 macOS 11.0+ 與 Swift 5.9+。使用 Swift Package Manager 加入：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeAppKit.git", from: "0.1.0")
]
```

或在 Xcode 中選擇 File → Add Package Dependencies，輸入 `https://github.com/nothingsh/DeclarativeAppKit`。

## 用法

### 掛載

```swift
view.addContent(page)                          // 填滿父視圖
view.addContent(page, safeArea: .all)          // 保持在安全區域內

view.addVStack(spacing: 8, safeArea: .top) {   // 建構 stack 並掛載
    title
    body
}
```

`addContent` 把視圖的四條邊固定到父視圖，並回傳帶有具體型別的該視圖。`safeArea` 中列出的邊改為固定到父視圖的安全區域。`addHStack`、`addVStack`、`addHScroll` 與 `addVScroll` 把建構與掛載合成一步。

### Stack

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

- `HStack` 與 `VStack` 是 `NSStackView` 的子類別，所有原生 stack API 仍然可用。建構 stack 不會掛載它。
- `alignment` 是交叉軸上的對齊：`VStack` 可用 `leading`、`center`、`trailing` 或 `fill`；`HStack` 可用 `top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline` 或 `fill`。`fill` 會延展每個元素。
- `spacing` 預設為 `0`，因此你看到的間距就是你寫下的間距。之後可以用 `.spacing(_:)`、`.alignment(_:)` 與 `.distribution(_:)` 修改。
- 內容閉包接受視圖、可選視圖、陣列、`if` / `else`、`switch`、`for` 與 `if #available`。

### 屬性 modifier

每個 modifier 設定同名的 AppKit 屬性，並以 `Self` 回傳該視圖，因此鏈式呼叫保留具體型別。

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
    .configure { $0.imageFrameStyle = .photo }   // 沒有對應 modifier 的屬性
```

| 型別 | Modifier |
| --- | --- |
| `NSView` | `configure`、`alphaValue`、`isHidden`、`toolTip`、`clipsToBounds`、`accessibilityLabel`、`accessibilityIdentifier` |
| `NSControl` | `isEnabled`、`isHighlighted`、`controlSize`、`font`、`alignment`、`lineBreakMode` |
| `NSTextField` | `stringValue`、`attributedStringValue`、`placeholderString`、`textColor`、`maximumNumberOfLines`、`isEditable`、`isSelectable` |
| `NSButton` | `title`、`attributedTitle`、`image`、`alternateTitle`、`alternateImage`、`imagePosition`、`bezelStyle`、`buttonType`、`state`、`contentTintColor` |
| `NSTextView` | `string`、`font`、`textColor`、`alignment`、`isEditable`、`isSelectable` |
| `NSSlider` | `doubleValue`、`minValue`、`maxValue`、`trackFillColor` |
| `NSSwitch` | `state` |
| `NSImageView` | `image`、`imageScaling`、`imageAlignment`、`contentTintColor` |

Label 就是以 `NSTextField(labelWithString:)` 或 `NSTextField(wrappingLabelWithString:)` 建立的 `NSTextField`。事件仍使用 AppKit 自己的 target–action 與委派。

### Padding 與 frame

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)                // 每條邊
.padding(.horizontal, 24)   // 只改指定的邊

stack.padding(horizontal: 16, vertical: 12)
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)

let avatar = NSImageView().frame(width: 48, height: 48)
let button = NSButton().frame(minWidth: 88)
let banner = NSImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- `padding` 是 stack 的 modifier。它在每條邊上都是固定距離，計入 stack 的尺寸，從不包含安全區域。要給單一視圖加上 padding，把它放進 stack。
- `frame` 給任意視圖加上 required 的尺寸約束。對同一條軸的後一次呼叫會取代前一次。

### Background 與 overlay

```swift
let card = VStack { name }
    .padding(16)
    .background(.quaternaryLabelColor)                     // stack 後方的顏色

let rounded = VStack { name }
    .padding(16)
    .background { roundedBox }                             // stack 後方的任意視圖

let avatar = NSImageView()
    .frame(width: 48, height: 48)
    .overlay(alignment: .bottomTrailing) { statusDot }     // 視圖前方的任意視圖
```

- 裝飾是以約束固定的子視圖；不會插入容器視圖，也沒有 `ZStack`。`alignment` 預設為 `.fill`，也可以是 `.topTrailing` 這樣的位置。
- 被裝飾視圖本身的內容決定其尺寸。

### Spacer

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

`Spacer` 沿所在 stack 的軸佔據剩餘長度，多個 spacer 平分它。`contentHuggingPriority(_:for:)` 與 `compressionResistancePriority(_:for:)` 決定其他視圖中哪一個先變大或先縮小。

### 捲動視圖

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

- `HScroll` 與 `VScroll` 是 `NSScrollView` 的子類別，以內建的 stack 排列元素，可透過 `stack` 存取。元素決定可捲動的長度；在另一條軸上，內容與捲動視圖一致。
- 巢狀放在 stack 中時，`HScroll` 的寬度需要由外部給定，`VScroll` 則是高度：像上面那樣使用 `.fill` 對齊，或使用 `frame`。
- 另一個方向的捲動會被轉交出去，因此指標停在 `HScroll` 上時，上面的頁面仍然可以垂直捲動。
- 捲動視圖不繪製背景，除非你設定 `.drawsBackground(true)`。

## 範例 App

`Example/Example.xcodeproj` 是一個小型 macOS App，以本地 package 的方式使用本函式庫。在 Xcode 中開啟它，選擇 `Example` scheme 並執行。它的視窗為每個畫面提供一個標籤頁，下面的程式碼片段節錄自這三個畫面。

### 個人資料卡片

程式碼的結構與畫面一致。狀態徽章透過 `overlay` 附著在頭像上，不需要包裝視圖或 `ZStack`。`bio` 與 `status` 是一般的屬性：按鈕直接修改它們，Auto Layout 負責調整卡片尺寸。沒有任何內容被重建。

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

// 之後，在按鈕的 action 中：
bio.stringValue(Self.longBio)
status.fillColor = .systemGray
```

</td>
<td width="300">
<img src="docs/images/example-profile.png" width="300" alt="個人資料卡片畫面">
</td>
</tr>
</table>

可重複使用的樣式只是以這些 modifier 為基礎的一個函式。`fill` 與 `card()` 是範例 App 自己的輔助方法，不屬於本函式庫：

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

### 表單

控制項就是一般的 `NSTextField`、`NSSwitch` 與 `NSSlider`，以 modifier 設定並保存為屬性。事件使用 AppKit 自己的 target–action 與委派。`Spacer` 把開關與數值推到 trailing 一側。

<table>
<tr>
<td>

```swift
private let newsletter = NSSwitch().state(.on)

private let frequency = NSSlider()
    .minValue(1)
    .maxValue(7)
    .doubleValue(3)

// 在 viewDidLoad 中：
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
<img src="docs/images/example-form.png" width="300" alt="表單畫面">
</td>
</tr>
</table>

### 捲動

`VScroll` 中巢狀放置 `HScroll` 列。內容閉包接受 `for` 迴圈，回傳 `NSView` 的小函式可以像其他視圖一樣組合。點按 *Add row* 會向一個保存為屬性的 stack 追加元素，可捲動的長度隨之更新。

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
<img src="docs/images/example-scroll.png" width="300" alt="捲動畫面">
</td>
</tr>
</table>

這些畫面會隨視窗尺寸的變化而調整。內容閉包只執行一次；之後的修改透過視圖本身進行，而不是透過資料繫結。

範例 App 的部署目標是 macOS 12.0，這是目前 Xcode 能建置的最低版本；請參閱[已知限制](#已知限制)。

## 已知限制

- 只有 `HStack` 與 `VStack` 支援 `fill` 對齊並保持 padding 固定。在一般的 `NSStackView` 上，AppKit 會讓過大的元素佔用交叉軸方向的 padding。
- `background(_:)` 會給 stack 增加一個子視圖，即繪製該顏色的 `NSBox`。
- 沒有 target–action 輔助，也沒有資料繫結。
- 本 package 宣告的最低版本是 macOS 11，API 皆依 macOS 11 的可用性審查過，但目前的工具鏈最低只能以 macOS 12 為目標建置，因此從未針對 macOS 11 本身建置或執行過。

## 開發

測試會呼叫 AppKit，在 macOS 上執行：

```sh
scripts/test-macos.sh
```

## 授權條款

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
