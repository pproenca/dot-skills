---
title: Prefer built-in animatable effects over custom Animatable conformances
tags: anim, animatable, performance, swiftui
---

## Prefer built-in animatable effects over custom Animatable conformances

The wrong default is writing a custom `Animatable` conformance for an effect the framework already animates. Built-in animatable attributes are interpolated with high efficiency, off the main thread, without calling into view code. A custom `Animatable` conformance inverts that: SwiftUI re-runs `body` for every frame of the animation on the main thread to feed the interpolated `animatableData` back through the view, making it far more expensive than the equivalent built-in effect. Custom `Animatable` is the tool of last resort, reserved for effects no built-in modifier can produce.

**Evidence of violation:** a type conforming to `Animatable` (including a `ViewModifier` or `GeometryEffect` with a custom `animatableData`) whose interpolated output drives only attributes built-in modifiers already animate — opacity, scale, rotation, offset/position, or color. PASS: the custom `Animatable` interpolates something no built-in effect produces — `Shape` path morphing, per-character text effects, progress-driven custom drawing — and the reviewer cites what it interpolates. N/A: no custom `Animatable` conformances in the target. A carve-out asserted without citable evidence fails closed.

**Incorrect (body re-runs on the main thread for every frame of the animation):**

```swift
import SwiftUI

struct FadeHighlight: ViewModifier, @MainActor Animatable {
    var opacityAmount: Double

    var animatableData: Double {
        get { opacityAmount }
        set { opacityAmount = newValue }
    }

    func body(content: Content) -> some View {
        content.opacity(opacityAmount)
    }
}

struct SightingBadge: View {
    @State private var isDimmed = false

    var body: some View {
        Button("Mark as seen") {
            isDimmed.toggle()
        }
        .modifier(FadeHighlight(opacityAmount: isDimmed ? 0.3 : 1))
        .animation(.easeInOut, value: isDimmed)
    }
}
```

**Correct (the framework interpolates opacity off the main thread without calling view code):**

```swift
import SwiftUI

struct SightingBadge: View {
    @State private var isDimmed = false

    var body: some View {
        Button("Mark as seen") {
            isDimmed.toggle()
        }
        .opacity(isDimmed ? 0.3 : 1)
        .animation(.easeInOut, value: isDimmed)
    }
}
```
