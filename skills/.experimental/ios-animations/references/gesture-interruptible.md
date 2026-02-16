---
title: Make All Gesture Animations Interruptible
impact: CRITICAL
impactDescription: Non-interruptible animations cause visible stutters 100% of the time when users redirect mid-flight. Springs maintain continuous velocity across interruptions, eliminating all redirection jank and matching iOS native behavior where any animation can be interrupted at any moment.
tags: gesture, interruptible, spring, cancel, redirect
---

## Make All Gesture Animations Interruptible

When a user lifts their finger and an animation begins settling to a target, they must be able to grab the element again and redirect it. This is what separates native iOS feel from web-style transitions. Easing curves like `.easeInOut` cannot be interrupted — they have a fixed duration and velocity profile, so grabbing the element mid-flight causes it to jump or stutter. Springs, by contrast, are stateful: they track current position and velocity at all times, so a new gesture can take over smoothly from wherever the spring currently is.

This is the single most important reason Apple made springs the default animation type in iOS 17. Every gesture completion animation should use a spring.

**Incorrect (easing curve locks the animation — grabbing mid-flight stutters):**

```swift
struct DraggablePanel: View {
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
            .frame(width: 300, height: 200)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = lastOffset + value.translation.height
                    }
                    .onEnded { _ in
                        // easeInOut: runs for exactly 0.35s with a fixed
                        // velocity curve. If the user taps again at 0.2s,
                        // the animation restarts from zero velocity — visible jank
                        withAnimation(.easeInOut(duration: 0.35)) {
                            offset = 0
                            lastOffset = 0
                        }
                    }
            )
    }
}
```

**Correct (spring preserves velocity — grabbing mid-flight feels continuous):**

```swift
@Equatable
struct DraggablePanel: View {
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .fill(.tint.gradient)
            .frame(width: 300, height: 200)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = lastOffset + value.translation.height
                    }
                    .onEnded { _ in
                        // .smooth spring: if the user grabs the panel while
                        // it is settling, the spring smoothly redirects
                        // to the new drag position with no velocity discontinuity
                        withAnimation(.smooth) {
                            offset = 0
                            lastOffset = 0
                        }
                    }
            )
    }
}
```

**`@GestureState` with spring reset makes this pattern automatic:**

```swift
@Equatable
struct InterruptibleCard: View {
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .fill(.tint.gradient)
            .frame(width: 280, height: 160)
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, transaction in
                        state = value.translation.height
                        // The transaction's animation applies both during
                        // the drag AND on the auto-reset when the gesture ends
                        transaction.animation = .smooth
                    }
            )
        // When the finger lifts, @GestureState resets dragOffset to 0
        // using the spring from the transaction — fully interruptible.
        // If the user grabs again mid-settle, the spring redirects smoothly.
    }
}
```

**Why easing curves break on interruption — the physics:**

```swift
// Easing curve: position is a pure function of time.
// At t=0.2s of a 0.35s animation, the velocity is predetermined.
// Interrupting forces a restart from t=0, causing a velocity jump.

// Spring: position is a function of (target, currentVelocity, currentPosition).
// Changing the target mid-flight preserves the current velocity.
// No jump — the spring smoothly curves toward the new target.

// This is why .animation(.smooth) and withAnimation(.smooth) exist:
// they produce interruptible animations by default.
```

**Benefits:**
- Users can grab, redirect, and release without any stutter or jump
- Rapid taps during settle feel natural — each tap smoothly redirects the spring
- No need to track or cancel in-flight animations manually
- Spring parameters (`.smooth`, `.snappy`, `.bouncy`) control the settle feel without sacrificing interruptibility

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158), [WWDC 2018 — Designing Fluid Interfaces](https://developer.apple.com/wwdc18/803)
