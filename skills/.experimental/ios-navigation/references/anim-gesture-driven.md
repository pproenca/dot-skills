---
title: Use Interactive Spring Animations for Gesture-Driven Transitions
impact: HIGH
impactDescription: 60fps gesture tracking with automatic velocity handoff
tags: anim, gesture, interactive, spring, velocity
---

## Use Interactive Spring Animations for Gesture-Driven Transitions

During active gestures, use `.interactiveSpring` to retarget animations smoothly as the user's finger moves. On gesture end, switch to a standard `.spring` that inherits the gesture's velocity for natural deceleration. Using linear or ease-based timing curves during gestures causes visible stuttering because they cannot retarget mid-flight, and snapping on release feels mechanical because velocity is discarded.

**Incorrect (linear animation during gesture, snap on release):**

```swift
// BAD: .linear cannot retarget mid-flight -- each new drag value
// queues a new animation, causing stutter at 30fps or worse.
// On release the card snaps without velocity, feeling mechanical.
struct DismissableCardView: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        CardContent()
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.linear(duration: 0.1)) {
                            offset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offset > 200 {
                                offset = 800 // WRONG: ignores release velocity
                                isDismissed = true
                            } else {
                                offset = 0 // WRONG: snaps back without momentum
                            }
                        }
                    }
            )
    }
}
```

**Correct (interactive spring during gesture, velocity-aware spring on release):**

```swift
@Equatable
struct DismissableCardView: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false
    @GestureState private var isDragging = false

    var body: some View {
        CardContent()
            .offset(y: offset)
            .opacity(opacity(for: offset))
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // interactiveSpring retargets smoothly each frame,
                        // keeping the card glued to the finger at 60fps
                        withAnimation(.interactiveSpring) {
                            offset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndTranslation.height
                        let shouldDismiss = offset > 200
                            || velocity > 500

                        // Standard spring inherits gesture velocity
                        // for natural deceleration
                        withAnimation(
                            .spring(duration: 0.5, bounce: 0)
                        ) {
                            if shouldDismiss {
                                offset = 1000 // Large value to animate offscreen
                                isDismissed = true
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
    }

    private func opacity(for offset: CGFloat) -> Double {
        let progress = min(max(offset / 400, 0), 1)
        return 1 - Double(progress) * 0.5
    }
}
```
