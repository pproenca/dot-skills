---
title: Use Canvas and TimelineView for High-Performance Rendering
impact: HIGH
impactDescription: bypasses SwiftUI view diffing for 10-50× throughput improvement, rendering 500+ elements at 120fps vs O(n) per-frame diffing with individual views
tags: perf, canvas, timelineview, particles, animation, rendering, metal
---

## Use Canvas and TimelineView for High-Performance Rendering

SwiftUI's view hierarchy adds per-view overhead for identity tracking, diffing, and layout. For animations with many moving elements (particles, charts with hundreds of data points, custom visualizations), this overhead dominates frame time. `Canvas` provides immediate-mode drawing that bypasses view diffing entirely, and `TimelineView` drives frame-rate updates without creating new view instances.

**Incorrect (each particle is a separate SwiftUI view -- O(n) view diffing per frame):**

```swift
struct ParticleField: View {
    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position(at: timeline.date))
                        .opacity(particle.opacity(at: timeline.date))
                }
            }
            // 500 particles = 500 view diffs per frame
        }
    }
}
```

**Correct (Canvas draws all particles in a single pass -- no view diffing):**

```swift
struct ParticleField: View {
    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date
                for particle in particles {
                    let position = particle.position(at: now)
                    let opacity = particle.opacity(at: now)
                    let rect = CGRect(
                        x: position.x - particle.size / 2,
                        y: position.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(particle.color)
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}
```

**Rendering resolved symbols for richer content:**

```swift
Canvas { context, size in
    // Resolve symbols once, reuse across draws
    let heartSymbol = context.resolveSymbol(id: "heart")

    for reaction in reactions {
        if let symbol = heartSymbol {
            context.draw(symbol, at: reaction.position)
        }
    }
} symbols: {
    Image(systemName: "heart.fill")
        .foregroundStyle(.red)
        .tag("heart")
}
```

**When to use Canvas + TimelineView:**
- Particle systems (snow, confetti, fireworks)
- Custom chart rendering with 100+ data points
- Game-like animations with many moving elements
- Any view with > 50 simultaneously-animated elements

**When to use regular views instead:**
- Interactive elements that need hit testing (Canvas draws are not tappable)
- Accessible content (Canvas content is invisible to VoiceOver)
- Small number of animated elements (< 20)

Reference: [Canvas Documentation](https://developer.apple.com/documentation/swiftui/canvas)
