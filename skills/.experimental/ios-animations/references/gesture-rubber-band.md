---
title: Rubber Band at Drag Boundaries
impact: HIGH
impactDescription: Rubber banding prevents 100% of perceived "freeze" issues at drag boundaries compared to hard clamps. Users maintain direct manipulation feedback even when exceeding limits by 200%+ of the boundary value.
tags: gesture, rubber-band, drag, boundary, elasticity
---

## Rubber Band at Drag Boundaries

When a user drags past a boundary, the interface must push back with increasing resistance — exactly the way iOS scroll views bounce. A hard clamp at the edge feels like the UI froze. A rubber band curve lets the user feel the boundary while seeing their touch still has effect, preserving the illusion of direct manipulation. Apple uses this everywhere: pull-to-refresh, over-scroll, notification shade, and Control Center.

The classic rubber band formula is `offset * (1.0 - (1.0 / ((offset * coefficient / limit) + 1.0)))`. For simpler cases, multiplying the excess drag by a damping factor like `0.3` produces a similar feel.

**Incorrect (hard clamp freezes the drag at the boundary):**

```swift
struct DraggableCard: View {
    @State private var offset: CGFloat = 0

    private let maxOffset: CGFloat = 200

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
            .frame(width: 300, height: 180)
            // Hard clamp: once the user hits 200pt, the card
            // stops dead — feels like it broke
            .offset(y: min(offset, maxOffset))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = max(0, value.translation.height)
                    }
                    .onEnded { _ in
                        withAnimation(.smooth) {
                            offset = 0
                        }
                    }
            )
    }
}
```

**Correct (rubber band formula gives diminishing resistance past the limit):**

```swift
@Equatable
struct DraggableCard: View {
    @State private var offset: CGFloat = 0

    private let limit: CGFloat = 200

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .fill(.tint.gradient)
            .frame(width: 300, height: 180)
            .offset(y: rubberBand(offset, limit: limit))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = max(0, value.translation.height)
                    }
                    .onEnded { _ in
                        withAnimation(.smooth) {
                            offset = 0
                        }
                    }
            )
    }

    /// Apple-style rubber band: offset increases with diminishing returns.
    /// `coefficient` controls stiffness — lower = stiffer resistance.
    private func rubberBand(
        _ offset: CGFloat,
        limit: CGFloat,
        coefficient: CGFloat = 0.55
    ) -> CGFloat {
        let clamped = max(offset, 0)
        if clamped < limit {
            return clamped
        }
        let excess = clamped - limit
        // Classic formula: diminishing returns on excess drag
        let rubber = limit + excess * coefficient / (1.0 + excess * coefficient / limit)
        return rubber
    }
}
```

**Extracting the rubber band for reuse:**

```swift
extension CGFloat {
    /// Rubber-band clamp that returns values in `0...limit` for inputs below the limit,
    /// and diminishing returns above. Matches the iOS over-scroll feel.
    func rubberClamped(to limit: CGFloat, coefficient: CGFloat = 0.55) -> CGFloat {
        let offset = max(self, 0)
        guard offset > limit else { return offset }
        let excess = offset - limit
        return limit + excess * coefficient / (1.0 + excess * coefficient / limit)
    }
}

// Usage in any drag handler:
.offset(y: offset.rubberClamped(to: 200))
```

**Benefits:**
- The user always sees a response to their touch, even past the boundary
- The resistance curve communicates "you are past the limit" without words or color changes
- Releasing the drag naturally springs back, matching iOS native behavior
- The coefficient parameter lets you tune stiffness per context (stiffer for small UI, looser for sheets)

Reference: [WWDC 2018 — Designing Fluid Interfaces](https://developer.apple.com/wwdc18/803)
