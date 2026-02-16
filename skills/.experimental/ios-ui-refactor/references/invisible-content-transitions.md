---
title: Use contentTransition for Changing Text and Numbers
impact: HIGH
impactDescription: eliminates layout jumps and abrupt text swaps on dynamic content, producing the polished numeric animations seen in Apple Fitness and Weather
tags: invisible, motion, text, rams-5, edson-product, contentTransition
---

## Use contentTransition for Changing Text and Numbers

Rams demanded that products serve as neutral tools — the transition should never overshadow the content change. contentTransition animates the change itself (individual digits rolling, text morphing) rather than wrapping the entire view in an opacity effect. Edson's product quality principle: the polish is in the details the user barely notices.

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

**When NOT to use:** Do not apply `.numericText` to rapidly updating values (60fps sensor data, timers updating every millisecond). For high-frequency updates, use `.monospacedDigit()` without animation to prevent animation queue buildup.

**Reference:** WWDC 2023 "Animate with springs" demonstrates `contentTransition(.numericText)` as the recommended approach for animating dynamic numeric content in SwiftUI.
