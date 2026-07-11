---
title: Compute per-frame visual transforms in visualEffect, not through State
tags: list, visualeffect, scroll, render-level
---

## Compute per-frame visual transforms in visualEffect, not through State

The wrong default is piping scroll or geometry values through `@State` on every frame just to feed a visual transform on the same content — the hand-rolled stretchy header. The source reserves state-driven observation for low-frequency changes: "some scenarios require high-frequency updates where modifying @State would trigger too many re-renders. In these cases, we can use the visualEffect(_:) modifier instead." Because `visualEffect` "operates purely on the render level," rapid changes skip body re-evaluation entirely and cannot create layout feedback loops.

**Evidence of violation:** `onScrollGeometryChange` or `onGeometryChange` writes `@State` on every scroll tick or frame, AND that state is consumed only by render-level transform modifiers (`scaleEffect`, `offset`, `opacity`, `rotationEffect`, `blur`). PASS: the transform is computed inside `.visualEffect { effect, geometry in … }` from the geometry proxy. N/A: the geometry state legitimately drives layout or structure elsewhere (presentation detents, showing a toolbar) rather than a pure visual transform, or the deployment target predates iOS 17 / macOS 14, where `visualEffect` is unavailable.

**Incorrect (every scroll tick re-evaluates the body through State):**

```swift
struct LandmarkDetailView: View {
    let imageName: String

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1 + max(0, scrollOffset) / 300)
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            -geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
    }
}
```

**Correct (render-level transform, no body re-evaluation per frame):**

```swift
struct LandmarkDetailView: View {
    let imageName: String

    var body: some View {
        ScrollView {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .visualEffect { effect, geometry in
                        let offset = max(0, geometry.frame(in: .scrollView).minY)
                        let scale = (geometry.size.height + offset) / geometry.size.height
                        return effect.scaleEffect(x: scale, y: scale, anchor: .bottom)
                    }
            }
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Adopting modern layout patterns”
