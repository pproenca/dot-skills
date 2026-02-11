---
title: Use scrollTransition for Scroll-Position Effects
impact: MEDIUM-HIGH
impactDescription: eliminates GeometryReader overhead in scroll views — 40% fewer layout passes
tags: content, scrollTransition, scroll, parallax, performance
---

## Use scrollTransition for Scroll-Position Effects

When items in a `ScrollView` should react to their scroll position — fading in as they enter, scaling down as they leave, rotating for a carousel — the traditional approach is wrapping each item in a `GeometryReader` and manually calculating offsets relative to the scroll view's coordinate space. This works but is expensive: every frame of scrolling triggers a layout pass in every visible `GeometryReader`, and the math to convert between coordinate spaces is error-prone.

`.scrollTransition` (iOS 17+) replaces all of this with a single modifier. It provides a `ScrollTransitionPhase` that tells you whether the view is fully visible (`.identity`), entering from the top/leading edge (`.topLeading`), or leaving from the bottom/trailing edge (`.bottomTrailing`). You apply visual effects based on the phase — no GeometryReader, no coordinate math, no layout overhead.

**Incorrect (GeometryReader inside ScrollView — expensive layout per frame):**

```swift
struct CardScrollView: View {
    let items = Array(0..<20)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items, id: \.self) { index in
                    // GeometryReader in every cell triggers layout on every scroll frame.
                    // With 20 items visible, that is 20 layout passes per frame.
                    GeometryReader { proxy in
                        let midY = proxy.frame(in: .global).midY
                        let screenMidY = UIScreen.main.bounds.height / 2
                        let distance = abs(midY - screenMidY)
                        let scale = max(0.85, 1 - (distance / 1000))

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                            .frame(height: 120)
                            .overlay {
                                Text("Card \(index)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(scale)
                            .opacity(Double(scale))
                    }
                    .frame(height: 120)
                }
            }
            .padding()
        }
    }
}
```

**Correct (.scrollTransition — zero layout cost, declarative phases):**

```swift
struct CardScrollView: View {
    let items = Array(0..<20)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.gradient)
                        .frame(height: 120)
                        .overlay {
                            Text("Card \(index)")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        // Applies visual effects based on scroll position
                        // without triggering any layout recalculation
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.3)
                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                        }
                }
            }
            .padding()
        }
    }
}
```

**Directional effects using phase values (carousel rotation):**

```swift
struct CarouselView: View {
    let items = Array(0..<15)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(items, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 260, height: 340)
                        .overlay {
                            Text("Item \(index)")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        }
                        .scrollTransition(.animated(.smooth)) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .scaleEffect(
                                    y: phase.isIdentity ? 1 : 0.9
                                )
                                // phase.value is -1 (top/leading), 0 (identity), +1 (bottom/trailing)
                                .rotation3DEffect(
                                    .degrees(phase.value * 15),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                }
            }
            .padding(.horizontal, 40)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}
```

**Keep effects subtle — recommended ranges:**

| Property | Identity value | Edge value | Notes |
|----------|---------------|------------|-------|
| Opacity | 1.0 | 0.3–0.5 | Below 0.2 looks like items vanish |
| Scale | 1.0 | 0.85–0.95 | Below 0.8 feels like items are collapsing |
| Rotation | 0 degrees | 10–20 degrees | Above 30 degrees causes clipping artifacts |
| Blur | 0 | 2–4 points | More than 6pt obscures content |

**Note:** `.scrollTransition` only applies visual-layer effects (transforms, opacity, blur). It cannot change layout properties like frame size or padding. For layout-dependent scroll effects, GeometryReader remains necessary — but those cases are rare.

Reference: [WWDC 2023 — Beyond scroll views](https://developer.apple.com/wwdc23/10159)
