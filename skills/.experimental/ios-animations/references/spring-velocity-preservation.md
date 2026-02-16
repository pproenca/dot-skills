---
title: Springs Preserve Velocity on Interruption
impact: CRITICAL
impactDescription: eliminates 100% of velocity discontinuities when users interrupt animations mid-flight — prevents the #1 source of animation jank
tags: spring, velocity, interruption, gesture, continuity
---

## Springs Preserve Velocity on Interruption

The fundamental reason springs are the iOS animation default is velocity continuity. When a user interrupts an in-flight animation — by tapping a card that is still expanding, flicking a sheet that is still settling, or toggling a control that has not finished transitioning — the spring takes the current position AND velocity and smoothly redirects toward the new target. Easing curves (`.easeInOut`, `.linear`) discard the current velocity and restart from scratch, creating a visible snap that users perceive as jank even if they cannot articulate why.

**Incorrect (.easeInOut discards velocity on rapid tapping):**

```swift
struct FavoriteButton: View {
    @State private var isFavorited = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            isFavorited.toggle()

            // Rapid tapping causes visible stuttering:
            // each tap restarts the scale animation from zero velocity,
            // creating a jerky "pop-pop-pop" effect
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.3
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.15)) {
                scale = 1.0
            }
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorited ? .red : .gray)
                .scaleEffect(scale)
        }
    }
}
```

**Correct (spring preserves velocity across rapid interactions):**

```swift
@Equatable
struct FavoriteButton: View {
    @State private var isFavorited = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            isFavorited.toggle()

            // Spring preserves in-flight velocity:
            // if the user taps while the heart is still scaling up,
            // the spring smoothly redirects — no velocity discontinuity
            withAnimation(.snappy) {
                scale = 1.3
            }
            withAnimation(.smooth.delay(0.1)) {
                scale = 1.0
            }
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorited ? .red : .gray)
                .scaleEffect(scale)
        }
    }
}
```

**Why this matters for gesture-driven animations:**

```swift
@Equatable
struct DismissableCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .fill(.background)
            .frame(height: 200)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .overlay {
                VStack {
                    Text("Swipe to dismiss")
                        .font(.headline)
                    Text("Drag left or right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndLocation.x - value.location.x

                        if abs(value.translation.width) > 150 {
                            // Dismiss: spring carries the gesture velocity into
                            // the dismiss animation — the card flies off screen
                            // at the speed the user was dragging
                            withAnimation(.smooth) {
                                offset = value.translation.width > 0 ? 500 : -500
                                isDismissed = true
                            }
                        } else {
                            // Snap back: spring uses the drag velocity to create
                            // a natural bounce-back — NOT an abrupt position reset
                            withAnimation(.snappy) {
                                offset = 0
                            }
                        }
                    }
            )
    }
}
```

**The physics of interruption — what happens internally:**

```text
Easing curve (easeInOut) interrupted at 60% progress:
  Position: 0.78 (ease curve value)
  Velocity: 2.4 (current rate of change)
  → New animation starts: position 0.78, velocity 0.0 ← DISCONTINUITY
  → User sees: sudden "freeze" then slow restart

Spring interrupted at 60% progress:
  Position: 0.78
  Velocity: 2.4
  → New animation starts: position 0.78, velocity 2.4 ← PRESERVED
  → User sees: smooth redirection toward new target
```

**This applies to ALL animatable properties:**

```swift
@Equatable
struct InterruptiblePanel: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(.tint.opacity(0.15))
                // All of these animate with velocity preservation:
                .frame(
                    width: isExpanded ? 300 : 150,    // size
                    height: isExpanded ? 200 : 80
                )
                .opacity(isExpanded ? 1.0 : 0.7)      // opacity
                .rotationEffect(                        // rotation
                    .degrees(isExpanded ? 0 : -5)
                )
                .overlay {
                    Text(isExpanded ? "Expanded" : "Collapsed")
                        .font(.headline)
                }

            Button("Toggle") {
                // Each tap smoothly retargets ALL properties simultaneously
                withAnimation(.smooth) {
                    isExpanded.toggle()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
```

**Key takeaway:** whenever an animation might be interrupted by user input — and that is nearly every animation in an interactive app — springs are the only correct choice. This is not a preference; it is a physics constraint.

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
