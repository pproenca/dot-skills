---
title: Size SF Symbols with text APIs and match weight and variant to context
tags: craft, sf-symbols, imagescale, symbol-variants
---

## Size SF Symbols with text APIs and match weight and variant to context

The wrong default is treating an SF Symbol like a bitmap: `Image(systemName:).resizable().frame(width: 18, height: 18)`. Symbols are drawn to align with text — resizing by frame distorts their optical weight, detaches them from Dynamic Type scaling, and makes them sit wrong next to the labels they accompany. Two adjacent failures follow the same misunderstanding: a symbol whose weight clashes with its neighboring text (the HIG directs matching the weights of interface icons and adjacent text), and fill/outline variants mixed arbitrarily within one bar — an iOS tab bar prefers the fill variant, a toolbar takes the outline variant, and fill within a tab bar signals selection, not decoration.

**Evidence of violation:** `Image(systemName:)` followed by `.resizable()` or an explicit `.frame(width:height:)` used to size the glyph — cite the chain; a symbol whose `.fontWeight`/`.font` weight differs from the text it sits beside in the same label or row — cite both; one toolbar or tab bar containing both `.fill` and outline variants of its item symbols where fill does not encode selection state — cite the items. PASS: symbols sized through the text system (`.font(.body)`, `.imageScale(.large)`, `.symbolVariant(_:)`), weights matching adjacent text, fill reserved for the selected tab state — the reviewer must cite the sizing API. N/A: a symbol with no variant counterpart (some symbols exist in only one form) — the reviewer must name the symbol; absent that evidence, fail closed. N/A: no SF Symbols in the target. Decorative fixed-size artwork built from symbols may size by frame only when it accompanies no text — the reviewer must cite the text-free context; absent that evidence, fail closed.

**Incorrect (a frame-sized symbol that ignores type scaling and optical weight):**

```swift
import SwiftUI

struct DeliveryStatusRow: View {
    let status: String

    var body: some View {
        HStack {
            // ⚠️ Bitmap-style sizing detaches the glyph from the text system
            Image(systemName: "bicycle")
                .resizable()
                .frame(width: 18, height: 18)
            Text(status)
                .font(.subheadline.weight(.semibold))
        }
    }
}
```

**Correct (the symbol rides the text system and matches its neighbor's weight):**

```swift
import SwiftUI

struct DeliveryStatusRow: View {
    let status: String

    var body: some View {
        HStack {
            Image(systemName: "bicycle")
                .font(.subheadline.weight(.semibold))
                .imageScale(.medium)
            Text(status)
                .font(.subheadline.weight(.semibold))
        }
    }
}
```

Reference: [HIG — SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols), [HIG — Icons](https://developer.apple.com/design/human-interface-guidelines/icons)
