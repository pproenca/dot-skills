---
title: Keep semantic colors in their defined roles
tags: color, semantic-colors, dark-mode, roles
---

## Keep semantic colors in their defined roles

The wrong default is treating the semantic palette as a swatch book — a separator gray that "looks right" as caption text, `placeholderText` as body copy, a background color as a foreground tint. Each dynamic color's light and dark variants are tuned for one role; cross-cast it and the pairing that happened to work in the authored appearance inverts or vanishes in the other. The families are disjoint: the **label family** (`label`, `secondaryLabel`, `tertiaryLabel`, `quaternaryLabel`, `placeholderText`) exists for text and symbols; the **surface family** (`systemBackground`/`secondarySystemBackground`/`tertiarySystemBackground`, the `systemGroupedBackground` set, the `systemFill` set, `separator`/`opaqueSeparator`) exists for surfaces, fills, and hairlines.

**Evidence of violation:** a surface-family color styled onto text or a symbol — e.g. `.foregroundStyle(Color(.separator))`, `Color(.systemFill)` as a text color, `placeholderText` on non-placeholder content; or a label-family color used as a container fill — e.g. `.background(Color(.label))`, a card filled with `secondaryLabel`. PASS: label-family colors on text/symbols, surface-family colors on backgrounds and fills, `separator` only on hairline strokes and dividers. N/A: no semantic colors appear in the target.

**Incorrect (separator gray cast as text inverts badly in Dark Mode):**

```swift
import SwiftUI

struct AccountFooter: View {
    let lastSynced: Date

    var body: some View {
        VStack(spacing: 8) {
            Divider()
            Text("Last synced \(lastSynced, format: .relative(presentation: .named))")
                .font(.footnote)
                .foregroundStyle(Color(.separator)) // ⚠️ separator is a hairline color — near-invisible as text in Dark Mode
        }
    }
}
```

**Correct (each family stays in its role):**

```swift
import SwiftUI

struct AccountFooter: View {
    let lastSynced: Date

    var body: some View {
        VStack(spacing: 8) {
            Divider() // separator color, in its role
            Text("Last synced \(lastSynced, format: .relative(presentation: .named))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Human Interface Guidelines — Color](https://developer.apple.com/design/human-interface-guidelines/color)
