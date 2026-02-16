---
title: Tune Custom Springs with response and dampingFraction
impact: HIGH
impactDescription: enables 10× finer motion tuning than the 3 presets via custom response (0.15–0.8s) and dampingFraction (0.5–1.0) — essential for branded animations where .smooth/.snappy/.bouncy are too generic
tags: spring, custom, response, dampingFraction, blendDuration
---

## Tune Custom Springs with response and dampingFraction

The three presets (`.smooth`, `.snappy`, `.bouncy`) cover most cases, but sometimes the UI element has a specific weight or feel that none of them match — a heavy bottom sheet, a lightweight tooltip, a springy pull-to-refresh. In these cases, use `Spring(response:dampingFraction:blendDuration:)` to dial in the exact feel. `response` controls how fast the spring moves (lower = faster, measured in seconds for a half-period), and `dampingFraction` controls bounce (1.0 = critically damped / no bounce, below 1.0 = bouncy, above 1.0 = overdamped / sluggish).

**Incorrect (guessing a duration-based easing curve for a heavy sheet):**

```swift
struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)

                Text("Order Summary")
                    .font(.title3.bold())

                OrderItemsList()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .background(.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
            .offset(y: isPresented ? dragOffset : 400)
            // A 0.4s easeInOut feels wrong for a heavy sheet:
            // - too slow for a light flick dismiss
            // - too fast for a heavy content panel
            // - no velocity preservation on drag release
            .animation(.easeInOut(duration: 0.4), value: isPresented)
            .animation(.easeInOut(duration: 0.4), value: dragOffset)
        }
    }
}
```

**Correct (custom spring tuned for a heavy sheet's weight):**

```swift
@Equatable
struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0

    // Heavy sheet: duration 0.55 feels weighty,
    // bounce 0.18 gives a subtle settle without oscillation
    // (equivalent to Spring(response: 0.55, dampingFraction: 0.82))

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: Spacing.md) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, Spacing.sm)

                Text("Order Summary")
                    .font(.title3.bold())

                OrderItemsList()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .background(.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: Radius.lg, topTrailingRadius: Radius.lg))
            .offset(y: isPresented ? dragOffset : 400)
            .animation(.spring(duration: 0.55, bounce: 0.18), value: isPresented)
            .animation(.spring(duration: 0.55, bounce: 0.18), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = max(0, value.translation.height)
                    }
                    .onEnded { value in
                        if value.translation.height > 150 || value.predictedEndTranslation.height > 300 {
                            isPresented = false
                        }
                        dragOffset = 0
                    }
            )
        }
    }
}
```

**Common custom spring values reference:**

| Use case | response | dampingFraction | Character |
|----------|----------|-----------------|-----------|
| Lightweight tooltip | 0.25 | 1.0 | Fast, no bounce |
| Standard UI (= `.smooth`) | 0.5 | 1.0 | Calm, stable |
| Heavy bottom sheet | 0.55 | 0.82 | Weighty, subtle settle |
| Pull-to-refresh | 0.4 | 0.7 | Springy feedback |
| Large modal | 0.6 | 0.9 | Deliberate, barely bounces |
| Responsive tap (= `.snappy`) | 0.3 | 1.0 | Quick, decisive |
| Playful element | 0.5 | 0.6 | Visible bounce |

**Understanding `blendDuration`:**

```swift
// blendDuration controls how quickly a new spring "takes over"
// from a currently-running animation. Default is 0.

// 0: instant takeover — the spring immediately starts from current state
Spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)

// 0.1-0.2: smooth blend — useful when chaining different spring types
// to avoid a subtle velocity pop
Spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)

// Rule of thumb: use 0 for most cases, 0.1 for gesture hand-offs
```

**Evaluating your custom spring with `Spring.value(target:)`:**

```swift
// Use this in a playground or debug view to visualize your spring
let spring = Spring(response: 0.55, dampingFraction: 0.82)

// How long until the spring is within 1% of target
let settlingDuration = spring.settlingDuration // seconds

// The spring value at a specific time
let valueAtHalfSecond = spring.value(
    target: 1.0,
    initialVelocity: 0,
    time: 0.5
)
```

**Rule of thumb:** start with the closest preset, then adjust `response` for speed and `dampingFraction` for bounce. Keep `dampingFraction` between 0.6 and 1.0 for UI (below 0.6 looks cartoonish, above 1.0 looks sluggish).

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
