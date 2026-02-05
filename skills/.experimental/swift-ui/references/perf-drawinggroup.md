---
title: Use drawingGroup for Complex Graphics
impact: MEDIUM
impactDescription: renders complex views to Metal texture, 5-10× faster
tags: perf, drawinggroup, metal, graphics, rendering
---

## Use drawingGroup for Complex Graphics

When rendering complex shapes, gradients, or many overlapping views, `drawingGroup()` flattens them into a single Metal texture. This dramatically improves performance.

**Incorrect (each element rendered separately):**

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

**Correct (flattened to single texture):**

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
