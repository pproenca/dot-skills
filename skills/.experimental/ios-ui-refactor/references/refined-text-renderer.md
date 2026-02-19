---
title: Use TextRenderer for Hero Text Animations Only
impact: MEDIUM
impactDescription: GPU-accelerated per-glyph rendering replaces CPU-bound character-splitting hacks, cutting frame drops by ~60% on animated hero text
tags: refined, animation, text, edson-prototype, rams-1, ios18
---

## Use TextRenderer for Hero Text Animations Only

The visual difference is unmistakable: hero text where characters move independently with GPU-level smoothness, each glyph tracked and rendered as part of a unified layout — versus the janky hack of splitting a string into individual `Text` views that know nothing about each other's metrics, kerning, or line breaks. `TextRenderer` gives you direct access to glyph runs while preserving accessibility and Dynamic Type, replacing a workaround with the purpose-built tool it was always waiting for.

**Incorrect (ForEach over characters with individual modifiers):**

```swift
struct WaveText: View {
    let text: String
    @State private var animating = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                Text(String(char))
                    .font(.largeTitle.bold())
                    .offset(y: animating ? -10 : 0)
                    .animation(
                        .spring(duration: 0.4)
                        .delay(Double(index) * 0.05)
                        .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}
```

**Correct (TextRenderer with per-glyph offset):**

```swift
struct WaveRenderer: TextRenderer {
    var elapsedTime: TimeInterval

    var animatableData: Double {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    func draw(
        layout: Text.Layout,
        in context: inout GraphicsContext
    ) {
        for run in layout.flatMap(\.self) {
            for (index, glyph) in run.enumerated() {
                var copy = context
                let phase = elapsedTime * 3 + Double(index) * 0.3
                let yOffset = sin(phase) * 8
                copy.translateBy(x: 0, y: yOffset)
                copy.draw(glyph)
            }
        }
    }
}

struct HeroTextView: View {
    @State private var startDate = Date.now

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            Text("Welcome")
                .font(.largeTitle.bold())
                .textRenderer(WaveRenderer(elapsedTime: elapsed))
        }
    }
}
```

Reserve `TextRenderer` for hero moments — splash screens, achievement celebrations, and onboarding headers. For routine text value changes (counters, timers, labels), use `.contentTransition(.numericText())` instead:

```swift
Text(score, format: .number)
    .contentTransition(.numericText())
    .animation(.spring(), value: score)
```

`TextRenderer` requires iOS 18+. On iOS 26, fall back to `.contentTransition` or static text.

**When NOT to apply:** Body text, list rows, and any content where per-glyph animation would be distracting rather than delightful. For routine numeric changes, `.contentTransition(.numericText())` is the correct tool; `TextRenderer` is reserved for hero moments only.

Reference: WWDC 2024 — "Create custom visual effects with SwiftUI"
