---
title: Pair color with a second cue when it carries state
tags: color, state, color-blindness, accessibility
---

## Pair color with a second cue when it carries state

The wrong default for status is a red-or-green tint and nothing else — a dot, a delta, a label that changes only its color with the state. Around one in twelve men cannot distinguish that pair, and the mapping itself is cultural: in Chinese-market financial apps red marks gains. When color is the only varying property, those users receive no signal at all. State needs a redundant channel — a different SF Symbol, a shape, a text change — with color as reinforcement.

**Evidence of violation:** a branch on a state value (ternary, `switch`, or lookup) where the only view property that varies across cases is a color feeding `.foregroundStyle`, `.fill`, or `.tint` — no symbol, shape, text, badge, or accessibility label differs between the branches; cite the branch. PASS: the same branch also varies a symbol (`arrow.up` vs `arrow.down`, `checkmark` vs `xmark`), a shape, or a text label that names the state — cite the second cue. N/A: color variation that carries no state — decorative per-item palette hues, category identity colors — the reviewer must cite the non-state nature of the variation; absent that evidence, fail closed.

**Incorrect (state exists only in the tint — invisible to color-blind users):**

```swift
import SwiftUI

struct HoldingRow: View {
    let holding: PortfolioHolding

    var body: some View {
        HStack {
            Text(holding.symbol)
                .font(.headline)
            Spacer()
            Text(holding.dayChange, format: .percent.precision(.fractionLength(2)))
                .foregroundStyle(holding.dayChange >= 0 ? .green : .red) // ⚠️ only the color varies with the state
        }
    }
}
```

**Correct (direction is redundantly encoded in the symbol; color reinforces):**

```swift
import SwiftUI

struct HoldingRow: View {
    let holding: PortfolioHolding

    var body: some View {
        HStack {
            Text(holding.symbol)
                .font(.headline)
            Spacer()
            Label {
                Text(holding.dayChange, format: .percent.precision(.fractionLength(2)))
            } icon: {
                Image(systemName: holding.dayChange >= 0 ? "arrow.up.right" : "arrow.down.right")
            }
            .foregroundStyle(holding.dayChange >= 0 ? .green : .red)
        }
    }
}
```

Reference: [Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [Human Interface Guidelines — Color](https://developer.apple.com/design/human-interface-guidelines/color)
