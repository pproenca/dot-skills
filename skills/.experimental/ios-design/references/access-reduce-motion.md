---
title: Respect Reduce Motion Preference
impact: HIGH
impactDescription: "prevents motion sickness for ~30% of users who enable Reduce Motion"
tags: access, reduce-motion, animation, accessibility, vestibular
---

## Respect Reduce Motion Preference

Users who enable Reduce Motion may experience motion sickness from animations. Check `accessibilityReduceMotion` and replace motion-heavy animations with simple fades.

**Incorrect (ignoring motion preference):**

```swift
struct CardFlip: View {
    @State private var isFlipped = false

    var body: some View {
        CardContent()
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                withAnimation(.spring(duration: 0.6)) {
                    isFlipped.toggle()
                }
            }
        // Rotates regardless of accessibility settings
    }
}
```

**Correct (adapting to motion preference):**

```swift
struct CardFlip: View {
    @State private var isFlipped = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        CardContent()
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                if reduceMotion {
                    isFlipped.toggle() // Instant change, no animation
                } else {
                    withAnimation(.spring(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                }
            }
    }
}
```

**Using Transaction for conditional animation:**

```swift
func toggleWithMotionRespect() {
    var transaction = Transaction()
    if !reduceMotion {
        transaction.animation = .spring(duration: 0.4)
    }
    withTransaction(transaction) {
        isExpanded.toggle()
    }
}
```

Reference: [Motion - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/motion)
