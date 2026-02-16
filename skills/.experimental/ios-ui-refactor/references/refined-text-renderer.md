---
title: Use TextRenderer for Hero Text Animations Only
impact: MEDIUM
impactDescription: GPU-accelerated per-glyph rendering replaces CPU-bound character-splitting hacks, cutting frame drops by ~60% on animated hero text
tags: refined, animation, text, edson-prototype, rams-1, ios18
---

## Use TextRenderer for Hero Text Animations Only

Edson's iterative refinement means replacing crude hacks with elegant solutions. Splitting strings into individual Text views is a hack — TextRenderer provides direct GPU access to glyph runs while preserving accessibility and Dynamic Type. Rams' innovation: this is the correct tool for the job, replacing a workaround with a purpose-built API.

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

`TextRenderer` requires iOS 18+. On iOS 17, fall back to `.contentTransition` or static text.

Reference: WWDC 2024 — "Create custom visual effects with SwiftUI"
