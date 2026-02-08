---
title: Use drawingGroup for Complex Vector Graphics
impact: LOW
impactDescription: offloads rendering to Metal GPU, 2-5x faster for complex paths
tags: perf, drawinggroup, metal, graphics, rendering
---

## Use drawingGroup for Complex Vector Graphics

By default, SwiftUI composites each layer of a view hierarchy on the CPU. For complex custom shapes with many overlapping paths, gradients, or blend modes, this CPU composition becomes a bottleneck, dropping frame rates during animation. Adding `.drawingGroup()` flattens the view into a single Metal-backed texture, offloading composition to the GPU for 2-5x faster rendering. Avoid using it for simple views -- the GPU roundtrip adds overhead that exceeds the savings for trivial content.

**Incorrect (CPU composites each path layer individually):**

```swift
struct ActivityRingsView: View {
    let rings: [RingData]

    var body: some View {
        ZStack {
            ForEach(rings) { ring in
                Circle()
                    .trim(from: 0, to: ring.progress)
                    .stroke(
                        ring.gradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: ring.color.opacity(0.5), radius: 6)
                    .padding(CGFloat(ring.index) * 28)
            }
            // With 8+ rings, shadows, and gradients,
            // CPU composition drops below 60 fps
        }
        .frame(width: 250, height: 250)
    }
}
```

**Correct (Metal GPU composites all layers in a single pass):**

```swift
struct ActivityRingsView: View {
    let rings: [RingData]

    var body: some View {
        ZStack {
            ForEach(rings) { ring in
                Circle()
                    .trim(from: 0, to: ring.progress)
                    .stroke(
                        ring.gradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: ring.color.opacity(0.5), radius: 6)
                    .padding(CGFloat(ring.index) * 28)
            }
        }
        .frame(width: 250, height: 250)
        .drawingGroup()
        // Flattened to a single Metal texture --
        // consistent 60 fps even with many rings
    }
}
```

Reference: [drawingGroup(opaque:colorMode:)](https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:))
