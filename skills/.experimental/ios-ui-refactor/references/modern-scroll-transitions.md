---
title: Use scrollTransition for Scroll-Position Visual Effects
impact: MEDIUM
impactDescription: Eliminates GeometryReader overhead inside scroll views, reducing layout passes by ~40% for lists with per-item visual effects
tags: modern, animation, scrolling, performance
---

## Use scrollTransition for Scroll-Position Visual Effects

`GeometryReader` inside a `ScrollView` forces an extra layout pass for every visible item on each scroll frame, degrading scroll performance and increasing code complexity. The `.scrollTransition()` modifier provides scroll-position-based visual effects with zero layout overhead because the system drives the interpolation directly from the scroll offset.

**Incorrect (GeometryReader for manual scroll offset calculation):**

```swift
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(items) { item in
            GeometryReader { proxy in
                let midY = proxy.frame(in: .global).midY
                let screenMid = UIScreen.main.bounds.height / 2
                let distance = abs(midY - screenMid)
                let opacity = max(0.3, 1 - distance / 400)
                let scale = max(0.85, 1 - distance / 2000)

                CardView(item: item)
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
            .frame(height: 200)
        }
    }
}
```

**Correct (scrollTransition with ScrollTransitionPhase):**

```swift
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(items) { item in
            CardView(item: item)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.3)
                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
                }
                .frame(height: 200)
        }
    }
}
```

Keep effects subtle to avoid motion discomfort — opacity range 0.3–1.0 and scale range 0.85–1.0 are safe defaults. For finer control, use `phase.value` (a `Double` from -1 to 1) to interpolate custom ranges. Do not combine `scrollTransition` with an explicit `animation()` modifier on the same properties — the system manages the timing.

Reference: WWDC 2023 — "Explore SwiftUI animation"
