---
title: Use contentTransition for Changing Text and Numbers
impact: HIGH
impactDescription: eliminates layout jumps and abrupt text swaps on dynamic content, producing the polished numeric animations seen in Apple Fitness and Weather
tags: invisible, motion, text, rams-5, edson-product, contentTransition
---

## Use contentTransition for Changing Text and Numbers

Watch a score change in Apple Fitness: each digit rolls independently, the way the numbers on an airport departure board click over one column at a time. You register the new value almost subconsciously because the motion tells you what changed and by how much. Now picture the same score snapping instantly from 42 to 43 — no transition, just a different number where the old one was. The jarring swap forces you to re-read the label to confirm what happened. The departure-board trick works because it animates the content itself, not a wrapper around it. No opacity fade, no scale bounce on the entire view — just the digits that actually changed, rolling into place. Rams called this neutrality: the transition should never overshadow the content it serves. The polish lives in the details users barely notice, and `.contentTransition(.numericText)` is exactly that kind of detail.

**Incorrect (opacity crossfade or no animation on number change):**

```swift
struct ScoreView: View {
    @State private var score = 0

    var body: some View {
        VStack {
            // No animation: number snaps instantly, feels static
            Text("\(score)")
                .font(.largeTitle.bold())

            // Opacity hack: entire label fades, digits don't animate individually
            Text("$\(score, format: .number)")
                .font(.title)
                .opacity(score > 0 ? 1 : 0.5)
                .animation(.easeInOut, value: score)

            Button("Add Point") {
                score += 1
            }
        }
    }
}
```

**Correct (contentTransition for polished number and text animation):**

```swift
struct ScoreView: View {
    @State private var score = 0

    var body: some View {
        VStack {
            // numericText: each digit rolls independently
            Text("\(score)")
                .font(.largeTitle.bold())
                .contentTransition(.numericText(value: Double(score)))
                .animation(.snappy, value: score)

            // numericText with formatted currency
            Text("$\(score, format: .number)")
                .font(.title)
                .contentTransition(.numericText(value: Double(score)))
                .animation(.snappy, value: score)

            Button("Add Point") {
                score += 1
            }
        }
    }
}
```

**Other content transitions:**

```swift
// Interpolate: smoothly morph between text styles or content
Text(isMetric ? "km" : "mi")
    .contentTransition(.interpolate)
    .animation(.smooth, value: isMetric)

// Symbol replacement with matched geometry
Label("Status", systemImage: isActive ? "checkmark.circle" : "circle")
    .contentTransition(.symbolEffect(.replace))
    .animation(.smooth, value: isActive)
```

**When NOT to apply:** Rapidly updating values (60fps sensor data, timers updating every millisecond) where `.numericText` would cause animation queue buildup. For high-frequency updates, use `.monospacedDigit()` without animation instead.

**Reference:** WWDC 2023 "Animate with springs" demonstrates `contentTransition(.numericText)` as the recommended approach for animating dynamic numeric content in SwiftUI.
