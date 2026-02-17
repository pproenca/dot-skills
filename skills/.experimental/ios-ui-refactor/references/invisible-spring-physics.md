---
title: Default to Spring Animations for All UI Transitions
impact: HIGH
impactDescription: eliminates 100% of abrupt animation stops and velocity discontinuities when users interrupt gestures mid-flight
tags: invisible, motion, spring, rams-5, edson-product, gesture
---

## Default to Spring Animations for All UI Transitions

Flick a card and watch it decelerate like a stone skipped across water — your finger lifts, and the card gradually settles as if it has weight. You feel in control because the screen obeys the same physics your hand expects. Now imagine the same flick but the card moves at constant speed and stops dead. The illusion breaks instantly: your hand says one thing, the screen says another, and for a split second the glass between you and the software becomes visible. Spring animations work because they model real inertia — acceleration, momentum, friction — not because they are clever, but because they are honest. Rams called this unobtrusiveness: the best design tool is the one you never notice. When motion respects physics, users never think "that was a nice animation." They simply feel a responsive interface.

> **See also:** [invisible-spring-presets](./invisible-spring-presets.md) for mapping the three named presets to interaction intent, and [invisible-no-easing](./invisible-no-easing.md) for why linear and easeInOut curves feel robotic.

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

**Exceptional (the creative leap) — spring with tuned personality:**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    // Two springs, two moods:
    // Expand — slightly bouncy, inviting, "come look"
    private let expandSpring = Spring(
        mass: 1.0, stiffness: 200, damping: 18
    )
    // Collapse — critically damped, decisive, "done"
    private let collapseSpring = Spring(
        mass: 1.0, stiffness: 300, damping: 28
    )

    private var activeSpring: Spring {
        isExpanded ? expandSpring : collapseSpring
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Trip to Brighton")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(activeSpring), value: isExpanded)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mar 14 – Mar 21")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Victorian terrace, five minutes from the sea. Two cats and a very lazy spaniel.")
                        .font(.body)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.regularMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            withAnimation(.spring(activeSpring)) {
                isExpanded.toggle()
            }
        }
    }
}
```

The two springs give the card a personality you feel but never consciously notice. The expand spring has low damping — it overshoots just slightly, like a door swinging open a touch further than it needs to, as if to say "welcome in." The collapse spring is stiffer and critically damped — it closes with quiet authority, no hesitation, no bounce. That asymmetry is what separates motion that has character from motion that merely moves. The card feels alive because it has opinions about how it wants to open and close.

**Benefits:**
- Rapid taps no longer cause visual stuttering; each tap smoothly redirects motion
- Gesture-driven animations (drag-to-dismiss, swipe) preserve finger velocity on release
- `withAnimation {}` with no arguments already uses springs on iOS 17+, so removing explicit easing is often the entire fix

**When NOT to apply:** Progress bars, indeterminate loading spinners, and continuous looping animations where constant-speed linear motion is the correct visual metaphor because no user gesture initiates or interrupts the movement.

**Reference:** WWDC 2023 "Animate with springs" — Apple recommends springs as the universal default because they model real-world physics and handle interruption without discontinuity.
