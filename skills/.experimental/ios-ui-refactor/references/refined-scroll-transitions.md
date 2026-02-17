---
title: Use scrollTransition for Scroll-Position Visual Effects
impact: MEDIUM
impactDescription: eliminates GeometryReader overhead inside scroll views, significantly reducing layout passes for lists with per-item visual effects
tags: refined, animation, scrolling, edson-prototype, rams-1, performance
---

## Use scrollTransition for Scroll-Position Visual Effects

There is a quiet satisfaction in cards that subtly scale and brighten as they enter the viewport — like spotlights finding their subject on a stage — compared to a flat list where every item carries the same visual weight regardless of scroll position. The difference is the feeling of a living surface vs a static wall of content. `scrollTransition` is Apple's own refinement of this idea, replacing the GeometryReader hack with a system-level API that handles timing, performance, and accessibility in one declarative gesture.

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

**Exceptional (the creative leap) — scroll-driven depth with perspective and blur:**

```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: 20) {
        ForEach(stories) { story in
            StoryCard(story: story)
                .frame(width: 280, height: 400)
                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.4)
                        .scaleEffect(phase.isIdentity ? 1 : 0.88)
                        .rotation3DEffect(
                            .degrees(phase.value * -18),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.4
                        )
                        .blur(radius: phase.isIdentity ? 0 : 3)
                }
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
.contentMargins(.horizontal, 40)
```

The 3D rotation and progressive blur create a carousel that lives in physical space -- cards turning away from you lose focus the way objects do in peripheral vision, and the one facing you is crisp and present. Combined with `viewAligned` snapping, the scroll feels like flipping through records in a crate: each flick lands on a card, and the world on either side softly recedes. This is the difference between scrolling through a list and turning pages in something you hold.

Keep effects subtle to avoid motion discomfort — opacity range 0.3–1.0 and scale range 0.85–1.0 are safe defaults. For finer control, use `phase.value` (a `Double` from -1 to 1) to interpolate custom ranges. Do not combine `scrollTransition` with an explicit `animation()` modifier on the same properties — the system manages the timing.

**When NOT to apply:** Data-dense lists (settings, contacts, logs) where every row should carry equal visual weight and scroll-driven effects would distract from rapid scanning. Also avoid on Reduce Motion configurations where positional visual effects can cause discomfort.

Reference: WWDC 2023 — "Explore SwiftUI animation"
