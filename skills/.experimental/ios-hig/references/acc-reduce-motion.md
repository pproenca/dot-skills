---
title: Respect Reduce Motion Preference
impact: HIGH
impactDescription: prevents motion sickness and discomfort for users with vestibular disorders
tags: acc, reduce-motion, animation, vestibular, preference
---

## Respect Reduce Motion Preference

When users enable "Reduce Motion", replace animations with fades or instant transitions. This prevents discomfort for users with vestibular disorders.

**Incorrect (ignoring motion preference):**

```swift
// Always uses bouncy animation
withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
    showDetail = true
}

// Parallax effects always on
ScrollView {
    GeometryReader { geo in
        Image("header")
            .offset(y: geo.frame(in: .global).minY / 2)
    }
}

// Auto-playing animations
LottieView(animation: .loading)
    .looping()

// Always bounces, even with Reduce Motion enabled
struct BouncyButton: View {
    @State private var isPressed = false

    var body: some View {
        Button("Tap Me") { }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
    }
}
```

**Correct (respects motion preference):**

```swift
// Check reduce motion setting
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animation
withAnimation(reduceMotion ? .none : .spring()) {
    showDetail = true
}

// Replace motion with crossfade
.transition(reduceMotion ? .opacity : .move(edge: .trailing))

// Button respecting preference
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

**Disable parallax when needed:**

```swift
struct ParallaxHeader: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if reduceMotion {
            Image("header")
        } else {
            GeometryReader { geo in
                Image("header")
                    .offset(y: geo.frame(in: .global).minY / 2)
            }
        }
    }
}

// Control auto-play
@Environment(\.accessibilityReduceMotion) var reduceMotion

LottieView(animation: .loading)
    .looping(!reduceMotion)
```

**Animation wrapper extension:**

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
- Allow essential animations (loading spinners)
- Test with Settings -> Accessibility -> Motion -> Reduce Motion

Reference: [Motion - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/motion)
