---
title: Use drawingGroup for Complex Graphics
impact: MEDIUM
impactDescription: offloads rendering to Metal GPU, 2-10x faster for complex vector paths
tags: perf, drawinggroup, metal, graphics, rendering
---

## Use drawingGroup for Complex Graphics

By default, SwiftUI composites each layer of a view hierarchy on the CPU. For complex custom shapes with many overlapping paths, gradients, or blend modes, this CPU composition becomes a bottleneck, dropping frame rates during animation. Adding `.drawingGroup()` flattens the view into a single Metal-backed texture, offloading composition to the GPU for 2-10x faster rendering. Avoid using it for simple views -- the GPU roundtrip adds overhead that exceeds the savings for trivial content.

**Incorrect (each element rendered separately on CPU):**

```swift
struct ParticleEffect: View {
    let particles: [Particle]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.gradient)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 2)
            }
        }
        // 500 particles = 500 separate render passes
    }
}
```

**Correct (flattened to single Metal texture):**

```swift
struct ParticleEffect: View {
    let particles: [Particle]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.gradient)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 2)
            }
        }
        .drawingGroup()  // Renders to single Metal texture
    }
}
```

**Activity rings with gradients and shadows:**

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

**Good candidates for drawingGroup:**
- Particle systems
- Complex gradients
- Many overlapping shapes
- Path-heavy visualizations
- Charts with many data points

**Not recommended for:**
- Simple views (overhead not worth it)
- Views with text (can reduce text quality)
- Views needing high-quality scaling
- Interactive elements (breaks hit testing inside)

**Combining with compositingGroup:**

```swift
ZStack {
    // Background layers
    ForEach(layers) { layer in
        layer.view
    }
}
.compositingGroup()  // Groups for blending
.drawingGroup()      // Renders to texture
```

**Measuring impact:**

```swift
// Use Instruments > Core Animation
// Look for "Offscreen-Rendered" layers
// drawingGroup should reduce render passes
```

Reference: [drawingGroup Documentation](https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:))
