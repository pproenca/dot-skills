---
title: Cap spring bounce on interface chrome
tags: motion, springs, bounce, damping
---

## Cap spring bounce on interface chrome

The wrong default when a design asks for "delight" is cranking spring bounce on ordinary interface elements — cards, sheets, rows, toolbars — until the UI wobbles like a toy. Apple's spring guidance is explicit: be cautious about bounce values higher than around 0.4, since they may feel too exaggerated for a UI element, and when unsure use bounce 0 (the most versatile spring). High bounce belongs to content that is deliberately playful — game elements, celebration moments — not to the chrome the user operates all day.

**Evidence of violation:** a filmstrip in which interface chrome — a card, list row, sheet, bar, button, toggle, or navigation element — visibly overshoots its settled position and comes back across tiles, corroborated by the spring parameter in code: a `.spring(duration:bounce:)` with a `bounce:` literal greater than 0.4, a `.bouncy(extraBounce:)` whose extra bounce pushes the total past 0.4 (`.bouncy` already carries a higher amount of bounce, so any positive `extraBounce` on it is suspect), or `dampingFraction` below 0.6. Cite the tiles, the literal, and the element it animates. When no recording covers the element's motion, the over-cap literal is a **candidate** — report it as N/A with the reason "recording evidence unavailable — candidate at file:line", never FAIL from the literal alone. PASS: the filmstrip settles without overshoot, or the code specifies bounce at or below 0.4, unspecified bounce (defaults to 0), or the presets `.smooth` / `.snappy` — cite the tiles or the call sites checked. N/A: the exaggerated spring animates content the target's own design frames as playful — a game board, a confetti celebration — the reviewer must cite the playful framing in the code or design notes; absent that evidence, fail closed. N/A: no spring parameters are specified anywhere in the target and no chrome overshoot appears in any filmstrip. The fix is lowering the cited literal — it never adds animation.

**Incorrect (a wobbling settings sheet reads as a toy, not a tool):**

```swift
import SwiftUI

struct WorkoutSummaryCard: View {
    let caloriesBurned: Int
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 8) {
            Text("\(caloriesBurned)")
                .font(.largeTitle.bold())
            Text("Calories")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary, in: .rect(cornerRadius: 16))
        .scaleEffect(isRevealed ? 1 : 0.8)
        .opacity(isRevealed ? 1 : 0)
        .onAppear {
            // ⚠️ bounce 0.7 on an ordinary summary card — exaggerated for a UI element
            withAnimation(.spring(duration: 0.5, bounce: 0.7)) {
                isRevealed = true
            }
        }
    }
}
```

**Correct (a smooth spring settles the card without wobble):**

```swift
import SwiftUI

struct WorkoutSummaryCard: View {
    let caloriesBurned: Int
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 8) {
            Text("\(caloriesBurned)")
                .font(.largeTitle.bold())
            Text("Calories")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary, in: .rect(cornerRadius: 16))
        .scaleEffect(isRevealed ? 1 : 0.8)
        .opacity(isRevealed ? 1 : 0)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                isRevealed = true
            }
        }
    }
}
```

Reference: [WWDC23 — Animate with springs](https://developer.apple.com/videos/play/wwdc2023/10158/), [Animation.bouncy](https://developer.apple.com/documentation/swiftui/animation/bouncy)
