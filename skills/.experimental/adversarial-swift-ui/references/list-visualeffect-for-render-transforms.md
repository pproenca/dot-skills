---
title: Compute per-frame visual transforms in visualEffect, not through State
tags: list, visualeffect, scroll, render-level
---

## Compute per-frame visual transforms in visualEffect, not through State

The wrong default is piping scroll or geometry values through `@State` on every frame just to feed a visual transform on the same content — the hand-rolled stretchy header. The source reserves state-driven observation for low-frequency changes: "some scenarios require high-frequency updates where modifying @State would trigger too many re-renders. In these cases, we can use the visualEffect(_:) modifier instead." Because `visualEffect` "operates purely on the render level," rapid changes skip body re-evaluation entirely, avoid the feedback loops of a transform influencing its own layout, and stay responsive under load.

**Evidence of violation:** `onScrollGeometryChange` or `onGeometryChange` writes `@State` on every scroll tick or frame, AND that state is consumed only by render-level transform modifiers (`scaleEffect`, `offset`, `opacity`, `rotationEffect`, `blur`). PASS: the transform is computed inside `.visualEffect { effect, geometry in ... }` from the geometry proxy, as in the source's stretchy-header example. PASS (carve-out): the scroll state drives non-visual logic — pagination, toolbar visibility, presentation parameters — the reviewer must cite that consumer to claim this; a carve-out asserted without evidence fails closed. N/A: no scroll- or frame-driven effects in the target, or the deployment target predates iOS 17 (`visualEffect`) / iOS 18 (`onScrollGeometryChange`).

**Incorrect (every scroll tick re-evaluates the body through State):**

```swift
import SwiftUI

struct Landmark {
    var imageURL: URL?
}

struct LandmarkImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url)
    }
}

struct LandmarkDetailView: View {
    let landmark: Landmark

    // ⚠️ Scroll offset round-trips through State on every frame
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack {
                LandmarkImage(url: landmark.imageURL)
                    .scaleEffect(
                        1 + max(0, scrollOffset) / 300,
                        anchor: .bottom
                    )

                // ... other subviews ...
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldValue, newValue in
            scrollOffset = -newValue
        }
        .ignoresSafeArea(edges: .top)
    }
}
```

**Correct (render-level transform, no body re-evaluation per frame):**

```swift
import SwiftUI

struct Landmark {
    var imageURL: URL?
}

struct LandmarkImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url)
    }
}

struct LandmarkDetailView: View {
    let landmark: Landmark

    var body: some View {
        ScrollView {
            VStack {
                LandmarkImage(url: landmark.imageURL)
                    .visualEffect { effect, geometry in
                        let currentHeight = geometry.size.height
                        let scrollOffset = geometry.frame(in: .scrollView).minY
                        let positiveOffset = max(0, scrollOffset)

                        let newHeight = currentHeight + positiveOffset
                        let scaleFactor = newHeight / currentHeight

                        return effect.scaleEffect(
                            x: scaleFactor, y: scaleFactor,
                            anchor: .bottom
                        )
                    }

                // ... other subviews ...
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
```
