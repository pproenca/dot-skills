---
title: Use drawingGroup() for Metal-Backed Complex Animations
impact: MEDIUM
impactDescription: rasterizes view subtree to a single Metal texture — eliminates per-frame layout for complex overlapping shapes
tags: craft, drawingGroup, metal, performance, rasterize
---

## Use drawingGroup() for Metal-Backed Complex Animations

SwiftUI renders views through Core Animation by default, compositing each view as a separate CALayer. For most UI this is efficient — Core Animation is optimized for discrete rectangles and text. But when you animate dozens of overlapping shapes — wave animations, particle effects, complex gradient meshes, or layered circles — Core Animation struggles. Each shape becomes its own layer, the compositor must resolve overlapping transparency per frame, and you start dropping frames on older devices.

`.drawingGroup()` tells SwiftUI to flatten the entire view subtree into a single Metal texture before compositing. Instead of 50 separate layers, the GPU renders one texture. This dramatically reduces compositing overhead for complex, overlapping visual effects. The tradeoff is that the entire subtree is rasterized — some effects like `shadow` and `blur` may render differently because they no longer operate on individual layers.

**Incorrect (50 overlapping Circle views without drawingGroup — dropped frames):**

```swift
struct WaveAnimation: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            Canvas { graphicsContext, size in
                // 50 overlapping semi-transparent circles,
                // each a separate Core Animation layer.
                // On iPhone 12 and older, this drops to ~40fps.
                for i in 0..<50 {
                    let t = Double(i) / 50.0
                    let x = size.width * t
                    let y = size.height / 2 + sin(time * 2 + t * .pi * 4) * 40

                    let rect = CGRect(
                        x: x - 15,
                        y: y - 15,
                        width: 30,
                        height: 30
                    )
                    graphicsContext.fill(
                        Circle().path(in: rect),
                        with: .color(.blue.opacity(0.3))
                    )
                }
            }
            .frame(height: 200)
        }
    }
}

// Alternative non-Canvas version that benefits more from drawingGroup:
struct OverlappingCircles: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<50, id: \.self) { i in
                    let t = Double(i) / 50.0
                    let yOffset = sin(time * 2 + t * .pi * 4) * 40

                    Circle()
                        .fill(.blue.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .offset(
                            x: CGFloat(i) * 6 - 150,
                            y: yOffset
                        )
                }
            }
            .frame(width: 300, height: 200)
            // Without drawingGroup: 50 CALayers composited per frame.
            // GPU compositor chokes on overlapping transparency.
        }
    }
}
```

**Correct (drawingGroup flattens to a single Metal texture):**

```swift
struct OverlappingCircles: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<50, id: \.self) { i in
                    let t = Double(i) / 50.0
                    let yOffset = sin(time * 2 + t * .pi * 4) * 40

                    Circle()
                        .fill(.blue.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .offset(
                            x: CGFloat(i) * 6 - 150,
                            y: yOffset
                        )
                }
            }
            .frame(width: 300, height: 200)
            // drawingGroup: all 50 circles are rasterized into a single
            // Metal texture. The compositor sees one layer instead of 50.
            // Consistent 60fps even on older devices.
            .drawingGroup()
        }
    }
}
```

**Production example — animated gradient orb:**

```swift
struct GradientOrb: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    let angle = Double(i) * (.pi / 3) + time * 0.5
                    let radius: CGFloat = 40

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    [.blue, .purple, .pink, .orange, .cyan, .mint][i],
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .offset(
                            x: cos(angle) * radius,
                            y: sin(angle) * radius
                        )
                        .blendMode(.screen)
                }
            }
            .frame(width: 200, height: 200)
            // Essential for overlapping blend modes — without drawingGroup,
            // blend modes apply per-layer in unexpected order
            .drawingGroup()
            .clipShape(Circle())
        }
    }
}
```

**When to use and when to avoid drawingGroup:**

| Scenario | Use drawingGroup? | Why |
|----------|-------------------|-----|
| 20+ overlapping animated shapes | Yes | Reduces compositing from N layers to 1 |
| Animated blend modes (.screen, .multiply) | Yes | Blend modes need correct compositing order |
| Animated gradients with many stops | Yes | Gradient interpolation is GPU-heavy |
| Simple button with shadow | No | Core Animation handles this efficiently |
| Text with blur effect | No | drawingGroup can break text rendering quality |
| Views with `.shadow` modifier | Caution | Shadow renders on the flattened texture, not individual shapes |

**How to diagnose when you need drawingGroup:**

1. Open Instruments with the "Core Animation" template
2. Enable "Color Blended Layers" — red areas are expensive overlapping transparency
3. If the animation area is solid red with multiple layers, add `.drawingGroup()`
4. Check the GPU frame time — it should drop significantly

**Warning:** do not apply `.drawingGroup()` by default. It adds overhead for simple views because the GPU must rasterize the texture before compositing. Only add it when profiling confirms that overlapping layer compositing is the bottleneck. Also note that `.drawingGroup()` flattens the accessibility tree for the subtree — ensure important accessible elements are outside the drawing group or have explicit accessibility labels.

Reference: [WWDC 2021 — Demystify SwiftUI](https://developer.apple.com/wwdc21/10022)
