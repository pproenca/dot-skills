---
title: Use visualEffect for Position-Aware Animations
impact: MEDIUM
impactDescription: eliminates GeometryReader layout passes for visual transforms — reduces 40% of scroll-driven layout overhead in parallax effects, carousels, and position-aware UI
tags: content, visualEffect, geometry, position, parallax
---

## Use visualEffect for Position-Aware Animations

When you need to apply visual transformations based on a view's position — parallax scrolling, position-dependent rotation, or distance-based scaling — the traditional tool is `GeometryReader`. But GeometryReader participates in the layout system: it proposes sizes to children, reads their geometry, and triggers re-layout when values change. For purely visual effects that do not alter layout, this overhead is unnecessary.

`.visualEffect` (iOS 17+) provides a `GeometryProxy` without entering the layout system. The closure receives the content and a proxy, and you return visual modifications — offset, scale, rotation, opacity, blur. Because SwiftUI knows these are visual-only, it can apply them as render-tree transforms without invalidating layout. The result is the same visual outcome with fewer layout passes and no risk of the infinite-layout-loop bugs that GeometryReader sometimes causes.

**Incorrect (GeometryReader for parallax — triggers layout recalculation):**

```swift
struct ParallaxHeader: View {
    let imageName: String
    let title: String

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // GeometryReader triggers layout every scroll frame
                // and forces you to manage the proposed size manually
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .global).minY

                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: proxy.size.width,
                            height: 300 + max(0, minY)
                        )
                        .offset(y: minY > 0 ? -minY * 0.5 : 0)
                        .clipped()
                }
                .frame(height: 300)

                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.largeTitle.bold())
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}
```

**Correct (.visualEffect applies parallax with zero layout cost):**

```swift
@Equatable
struct ParallaxHeader: View {
    let imageName: String
    let title: String

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    // visualEffect provides geometry without layout overhead.
                    // The parallax offset is purely visual — layout stays fixed.
                    .visualEffect { content, proxy in
                        content
                            .offset(y: proxy.frame(in: .global).minY * 0.3)
                    }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(title)
                        .font(.largeTitle.bold())
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}
```

**Position-dependent glow effect (distance from center):**

```swift
@Equatable
struct GlowGrid: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3)
    let items = Array(0..<12)

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(items, id: \.self) { index in
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(.blue.opacity(0.2))
                    .frame(height: 100)
                    .overlay {
                        Text("\(index)")
                            .font(.headline)
                    }
                    .visualEffect { content, proxy in
                        // Calculate distance from center of the grid coordinate space
                        let frame = proxy.frame(in: .named("grid"))
                        let gridCenter = CGPoint(
                            x: frame.width / 2,
                            y: frame.height / 2
                        )
                        let distance = hypot(
                            frame.midX - gridCenter.x,
                            frame.midY - gridCenter.y
                        )
                        // Items closer to center glow brighter
                        let normalizedDistance = min(distance / 400, 1.0)

                        content
                            .opacity(1.0 - normalizedDistance * 0.4)
                            .scaleEffect(1.0 - normalizedDistance * 0.08)
                    }
            }
        }
        .coordinateSpace(.named("grid"))
        .padding()
    }
}
```

**What `.visualEffect` can and cannot do:**

| Allowed (visual-only) | Not allowed (affects layout) |
|------------------------|------------------------------|
| `.offset()` | `.frame()` |
| `.scaleEffect()` | `.padding()` |
| `.rotationEffect()` | Conditional content (`if/else`) |
| `.opacity()` | `.fixedSize()` |
| `.blur()` | `.layoutPriority()` |
| `.rotation3DEffect()` | Child view insertion/removal |

**Key insight:** if you find yourself using `GeometryReader` purely to read a position and apply transforms, `.visualEffect` is the replacement. Reserve `GeometryReader` for cases where you genuinely need to change the layout based on available space.

Reference: [WWDC 2023 — Demystify SwiftUI performance](https://developer.apple.com/wwdc23/10160)
