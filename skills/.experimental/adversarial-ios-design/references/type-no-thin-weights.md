---
title: Avoid Ultralight Thin and Light weights on UI text
tags: type, font-weight, legibility
---

## Avoid Ultralight Thin and Light weights on UI text

The wrong default is reaching for a thin weight to make a heading feel "elegant." Apple's guidance is the opposite: light weights are difficult to see at interface sizes, where hairline strokes lose contrast against any background and disappear entirely for low-vision users. Interface text uses Regular, Medium, Semibold, or Bold; emphasis comes from size and hierarchy, not from thinning the strokes.

**Evidence of violation:** `.fontWeight(.ultraLight)`, `.fontWeight(.thin)`, `.fontWeight(.light)`, `Font.Weight.ultraLight/.thin/.light`, or the `UIFont.Weight` equivalents applied to UI text — cite the modifier site. PASS: weights limited to regular, medium, semibold, or bold on interface text. A light weight on a display-scale numeral — a hero value styled `.largeTitle` or with a size of 34 or more, where the strokes stay thick in absolute terms — may be claimed as a carve-out with the size citable at the same call site; absent that evidence, fail closed. N/A: no explicit weight modifiers in the target.

**Incorrect (hairline strokes vanish at interface sizes):**

```swift
import SwiftUI

struct BoardingPassHeader: View {
    let pass: BoardingPass

    var body: some View {
        VStack(spacing: 4) {
            Text(pass.route)
                .font(.title3)
                .fontWeight(.ultraLight) // ⚠️ thin strokes are hard to see at this size
            Text("Gate \(pass.gate) · Boards \(pass.boardingTime, format: .dateTime.hour().minute())")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Correct (weight stays legible; hierarchy comes from size and color):**

```swift
import SwiftUI

struct BoardingPassHeader: View {
    let pass: BoardingPass

    var body: some View {
        VStack(spacing: 4) {
            Text(pass.route)
                .font(.title3)
                .fontWeight(.semibold)
            Text("Gate \(pass.gate) · Boards \(pass.boardingTime, format: .dateTime.hour().minute())")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Human Interface Guidelines — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
