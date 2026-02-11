---
title: Default to Spring Animations for All UI Transitions
impact: HIGH
impactDescription: Eliminates 100% of abrupt animation stops and velocity discontinuities when users interrupt gestures mid-flight
tags: motion, animation, spring, gesture
---

## Default to Spring Animations for All UI Transitions

Spring animations are the SwiftUI default since iOS 17, and for good reason: they are the only animation type that preserves velocity continuity. When a user interrupts a gesture or triggers a new animation before the current one finishes, springs seamlessly blend the motion. Easing curves (easeInOut, linear) snap to new targets, creating visible jank.

**Incorrect (hardcoded easing curves that break on interruption):**

```swift
struct CardView: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: isExpanded ? 300 : 120)
                // easeInOut stops dead if tapped mid-animation
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                .onTapGesture {
                    isExpanded.toggle()
                }
        }
    }
}
```

**Correct (spring animation that handles interruptions gracefully):**

```swift
struct CardView: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: isExpanded ? 300 : 120)
                // .smooth spring: no bounce, natural deceleration
                .animation(.smooth, value: isExpanded)
                .onTapGesture {
                    isExpanded.toggle()
                }
        }
    }
}
```

**Benefits:**
- Rapid taps no longer cause visual stuttering; each tap smoothly redirects motion
- Gesture-driven animations (drag-to-dismiss, swipe) preserve finger velocity on release
- `withAnimation {}` with no arguments already uses springs on iOS 17+, so removing explicit easing is often the entire fix

**Reference:** WWDC 2023 "Animate with springs" — Apple recommends springs as the universal default because they model real-world physics and handle interruption without discontinuity.
