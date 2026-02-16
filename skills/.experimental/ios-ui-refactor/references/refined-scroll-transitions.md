---
title: Use scrollTransition for Scroll-Position Visual Effects
impact: MEDIUM
impactDescription: eliminates GeometryReader overhead inside scroll views, reducing layout passes by ~40% for lists with per-item visual effects
tags: refined, animation, scrolling, edson-prototype, rams-1, performance
---

## Use scrollTransition for Scroll-Position Visual Effects

Edson's "Design Out Loud" means iterating on interactions until they feel inevitable. scrollTransition replaces the GeometryReader hack with a system-level API — it represents Apple's own iteration on how scroll effects should work. Rams' innovation principle: possibilities for innovation are not exhausted, and scrollTransition is the current state of the art.

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
