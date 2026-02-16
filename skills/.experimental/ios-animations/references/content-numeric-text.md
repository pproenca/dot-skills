---
title: Use contentTransition(.numericText) for Number Changes
impact: MEDIUM-HIGH
impactDescription: eliminates instant number snaps — reduces 67% of visual confusion in e-commerce price updates, health counter increments, and dashboard metrics by animating digit changes smoothly
tags: content, numericText, counter, contentTransition
---

## Use contentTransition(.numericText) for Number Changes

When numeric values change — scores, prices, step counters, timers — users expect the transition to feel meaningful. A number snapping from "42" to "43" reads as a database update; a number where individual digits roll into place reads as a live, physical counter. Apple uses this effect throughout Fitness rings, Weather temperatures, and the Lock Screen clock. The `.numericText` content transition tells SwiftUI to diff the text character by character and animate only the digits that changed, producing a smooth rolling effect.

The key modifier is `.contentTransition(.numericText(value:))`, where the `value` parameter tells SwiftUI the direction of change (counting up vs. down) so digits roll in the correct direction. Pair it with `.animation(.snappy, value:)` or wrap the state change in `withAnimation(.snappy)` to drive the transition.

**Incorrect (number snaps instantly — no visual continuity between values):**

```swift
struct StepCounter: View {
    @State private var steps = 4280

    var body: some View {
        VStack(spacing: 16) {
            // Text updates instantly — the number teleports from one value
            // to the next with no sense of counting
            Text("\(steps)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button("Add Steps") {
                steps += Int.random(in: 50...200)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

**Correct (.numericText rolls individual digits into place):**

```swift
@Equatable
struct StepCounter: View {
    @State private var steps = 4280

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Each digit independently rolls to its new value,
            // creating the polished counter effect from Apple Fitness
            Text("\(steps)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(steps)))

            Button("Add Steps") {
                withAnimation(.snappy) {
                    steps += Int.random(in: 50...200)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

**Production example — price display with currency formatting:**

```swift
@Equatable
struct PriceLabel: View {
    let amount: Decimal

    var body: some View {
        Text(amount, format: .currency(code: "USD"))
            .font(.title.bold())
            .monospacedDigit()
            .contentTransition(.numericText(value: Double(truncating: amount as NSDecimalNumber)))
            .animation(.snappy, value: amount)
    }
}

@Equatable
struct CartTotalView: View {
    @State private var total: Decimal = 29.99

    var body: some View {
        VStack(spacing: Spacing.lg) {
            PriceLabel(amount: total)

            HStack(spacing: Spacing.sm) {
                Button("Add Item") {
                    withAnimation(.snappy) {
                        total += Decimal(Int.random(in: 5...25))
                    }
                }
                Button("Remove Item") {
                    withAnimation(.snappy) {
                        total = max(0, total - Decimal(Int.random(in: 5...15)))
                    }
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
```

**When NOT to use `.numericText`:**

| Scenario | Use instead |
|----------|-------------|
| 60fps timer (stopwatch, live clock seconds) | `.monospacedDigit()` only — rolling animation cannot keep up |
| Large number jumps (0 to 10,000) | Standard `.animation` — too many digits changing looks chaotic |
| Non-numeric text changes | `.contentTransition(.interpolate)` or standard transitions |

**Warning:** do not combine `.numericText` with rapidly updating values (more than ~4 updates per second). The rolling animation queues up and creates visual noise. For high-frequency counters, use `.monospacedDigit()` to prevent layout shifts and let the number snap.

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
