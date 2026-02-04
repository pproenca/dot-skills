---
title: Respect Reduce Motion Preference
impact: HIGH
impactDescription: prevents motion sickness and discomfort for sensitive users
tags: a11y, motion, animation, vestibular
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
```

**Correct (respects motion preference):**

```swift
// Check reduce motion setting
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animation
withAnimation(reduceMotion ? .none : .spring()) {
    showDetail = true
}

// Or use system-aware animation
.animation(.default, value: isExpanded)
// System automatically adjusts for reduce motion

// Replace motion with crossfade
.transition(reduceMotion ? .opacity : .move(edge: .trailing))

// Disable parallax when needed
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

**Motion guidelines:**
- Replace sliding transitions with fades
- Disable parallax effects
- Stop auto-playing animations
- Allow essential animations (loading spinners)
- Test with Settings → Accessibility → Motion → Reduce Motion

Reference: [Motion - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/motion)
