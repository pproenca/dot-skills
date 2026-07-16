---
title: Animate changing numbers with numeric text transitions on fixed-width digits
tags: craft, numeric-text, contenttransition, monospaced-digits
---

## Animate changing numbers with numeric text transitions on fixed-width digits

The wrong default for a counter, timer, price, or stat tile is a plain `Text` whose digits hard-swap on every update and whose proportional glyph widths make the value — and every sibling laid out after it — jitter horizontally as digits change. The remedy is three-part and each part is checkable: `.contentTransition(.numericText())` rolls individual digits the way system clocks and timers do (`countsDown: true` when the value decreases), `.monospacedDigit()` (or a tabular-figures font) fixes digit widths so layout stays still, and the mutation itself must be animated — `contentTransition` only has an effect within the context of an `Animation`, so the modifier on an unanimated mutation is dead code.

**Evidence of violation:** a `Text` displaying a numeric value bound to state that mutates at runtime (a timer tick, a live price, a counter) with no `.contentTransition(.numericText())`; a runtime-updating numeric `Text` in a proportional font with no `.monospacedDigit()` or tabular-figures equivalent; or `.contentTransition(.numericText())` present while the driving mutation is wrapped in no `withAnimation` and no `.animation(_:value:)` covers the view — cite the mutation site; a countdown rendered with `countsDown` omitted or `false`. PASS: the changing `Text` carries `.contentTransition(.numericText(countsDown:))` matching the value's direction plus `.monospacedDigit()`, and the mutation is animated — the reviewer must cite all three. N/A: numeric text that never changes after initial render — the reviewer must cite the constant source; absent that evidence, fail closed. N/A: a standard control's own title label (a `Stepper` or `Picker` string-interpolated title, a `Slider` label) — the rule's subject is a `Text` view displaying a changing metric (counter, timer, price, stat readout), not a control's self-labeling; cite the control. N/A: no runtime-changing numeric text in the target. Requires iOS 17 for `.numericText(countsDown:)`; iOS 16 targets using `.numericText()` satisfy the rule.

**Incorrect (digits hard-swap and the row jitters as widths change):**

```swift
import SwiftUI

struct WorkoutCalorieCounter: View {
    let calories: Int

    var body: some View {
        // ⚠️ No content transition and proportional digits — the value snaps and shifts layout
        Text("\(calories)")
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
    }
}
```

**Correct (digits roll like the system timer and layout holds still):**

```swift
import SwiftUI

struct WorkoutCalorieCounter: View {
    let calories: Int

    var body: some View {
        Text("\(calories)")
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.default, value: calories)
    }
}
```

Reference: [ContentTransition.numericText(countsDown:)](https://developer.apple.com/documentation/swiftui/contenttransition/numerictext(countsdown:)), [contentTransition(_:)](https://developer.apple.com/documentation/swiftui/view/contenttransition(_:)), [Font.monospacedDigit()](https://developer.apple.com/documentation/swiftui/font/monospaceddigit())
