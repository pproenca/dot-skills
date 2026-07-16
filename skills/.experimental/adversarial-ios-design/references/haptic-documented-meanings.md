---
title: Use system haptic patterns with their documented meanings
tags: haptic, sensoryfeedback, semantics, patterns
---

## Use system haptic patterns with their documented meanings

The wrong default is grabbing whatever feedback constant compiles — `.success` when a screen appears, `.selection` as a generic tap effect, `.error` for a cancel. Users learn the system's haptic vocabulary across every app on the device: success means a task completed, error means something went wrong, selection means a value is changing under the finger. Apple's guidance is to use system-provided patterns according to their documented meanings and, if the documented use case doesn't fit, to avoid repurposing the pattern to mean something else — a success buzz on a non-completion (or the same pattern for opposite outcomes) actively miscommunicates.

**Evidence of violation:** a `.sensoryFeedback(.success, trigger:)` whose trigger state is not a completed task or action; `.error` on a path that is not an error (cancellation, ordinary dismissal); `.selection` where no UI element's value is changing (a plain navigation button, a screen appearance); the same pattern fired for both a positive and a negative outcome; `.increase`/`.decrease` unconnected to a value crossing a threshold. Evidence is the semantic state of the trigger, citable at the binding site — quote the trigger and what it represents. PASS: each constant's trigger matches its documented meaning — `.success` on task completion, `.warning` on a warning-producing outcome, `.error` on failures, `.selection` on changing values, `.impact` on a collision or physical-metaphor moment with a matching visual — cite the bindings checked. N/A: the target plays no haptics.

**Incorrect (a success haptic on tab appearance — the pattern's meaning is repurposed):**

```swift
import SwiftUI

struct PortfolioTabView: View {
    @State private var didAppear = false

    var body: some View {
        List {
            Text("Holdings")
            Text("Watchlist")
        }
        .onAppear { didAppear = true }
        // ⚠️ .success signals a completed task — appearing is not an outcome
        .sensoryFeedback(.success, trigger: didAppear)
    }
}
```

**Correct (the success pattern is reserved for an actual completed action):**

```swift
import SwiftUI

struct PortfolioTabView: View {
    @State private var orderPlaced = false

    var body: some View {
        List {
            Text("Holdings")
            Text("Watchlist")
            Button("Place Order") {
                orderPlaced = true
            }
        }
        .sensoryFeedback(.success, trigger: orderPlaced) { _, newValue in
            newValue
        }
    }
}
```

Reference: [Human Interface Guidelines — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics), [sensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
