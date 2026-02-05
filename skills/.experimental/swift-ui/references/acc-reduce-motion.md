---
title: Respect Reduce Motion Preference
impact: MEDIUM-HIGH
impactDescription: prevents motion sickness for vestibular disorder users
tags: acc, reduce-motion, animation, vestibular, preference
---

## Respect Reduce Motion Preference

Users with vestibular disorders can enable "Reduce Motion" in Settings. Respect this by simplifying or removing animations.

**Incorrect (ignoring reduce motion):**

```swift
struct BouncyButton: View {
    @State private var isPressed = false

    var body: some View {
        Button("Tap Me") { }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
            // Always bounces, even with Reduce Motion enabled
    }
}
```

**Correct (respecting preference):**

```swift
struct BouncyButton: View {
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button("Tap Me") { }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(reduceMotion ? .none : .spring(), value: isPressed)
    }
}
```

**Alternative animations for reduce motion:**

```swift
struct AnimatedView: View {
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if isVisible {
            ContentView()
                .transition(reduceMotion ? .opacity : .slide)
        }
    }
}
```

**Using withAnimation conditionally:**

```swift
func toggle() {
    if reduceMotion {
        isExpanded.toggle()  // Instant change
    } else {
        withAnimation(.spring()) {
            isExpanded.toggle()
        }
    }
}
```

**Animation wrapper:**

```swift
extension View {
    func conditionalAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        self.animation(reduceMotion ? nil : animation, value: value)
    }
}
```

**What to simplify with Reduce Motion:**
- Replace sliding/bouncing with fades
- Remove parallax effects
- Disable auto-playing animations
- Reduce transition durations
- Use crossfades instead of spatial transitions

Reference: [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion#Reducing-motion)
