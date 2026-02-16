---
title: Always Provide Reduce Motion Fallback
impact: CRITICAL
impactDescription: 10-15% of users enable Reduce Motion due to vestibular disorders — missing fallbacks cause nausea, disorientation, and immediate app abandonment
tags: empathy, motion, accessibility, kocienda-empathy, edson-people, reduce-motion
---

## Always Provide Reduce Motion Fallback

Kocienda tested the iPhone keyboard under every condition imaginable because empathy meant anticipating the user's reality, not assuming it. A user with a vestibular disorder who enables Reduce Motion is not an edge case — they are 10-15% of your audience. When your bouncing onboarding animation triggers their vertigo, you have failed at the most basic act of empathy. Edson's people-first design demands that every user, regardless of physical sensitivity, can use the product without discomfort.

**Incorrect (animations with no Reduce Motion check):**

```swift
struct OnboardingCard: View {
    @State private var isVisible = false

    var body: some View {
        VStack {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .offset(y: isVisible ? 0 : 100)
                .opacity(isVisible ? 1 : 0)
                .animation(.bouncy, value: isVisible)

            Text("Welcome!")
                .font(.largeTitle.bold())
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(.bouncy.delay(0.2), value: isVisible)
        }
        .onAppear { isVisible = true }
    }
}
```

**Correct (crossfade fallback when Reduce Motion is enabled):**

```swift
struct OnboardingCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        VStack {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 100))
                .opacity(isVisible ? 1 : 0)
                .animation(
                    reduceMotion ? .smooth(duration: 0.1) : .bouncy,
                    value: isVisible
                )

            Text("Welcome!")
                .font(.largeTitle.bold())
                .scaleEffect(reduceMotion ? 1 : (isVisible ? 1 : 0.5))
                .opacity(isVisible ? 1 : 0)
                .animation(
                    reduceMotion ? .smooth(duration: 0.1) : .bouncy.delay(0.2),
                    value: isVisible
                )
        }
        .onAppear { isVisible = true }
    }
}
```

**Reusable helper for consistent handling:**

```swift
extension Animation {
    static func adaptive(
        _ animation: Animation,
        reduceMotion: Bool
    ) -> Animation {
        reduceMotion ? .smooth(duration: 0.1) : animation
    }
}

// Usage
.animation(.adaptive(.bouncy, reduceMotion: reduceMotion), value: isVisible)
```

**What to reduce, not remove:** Replace spatial movement (slides, bounces, zooms) with opacity crossfades. Keep opacity transitions under 150ms. Never remove the state change entirely — the user still needs to see that something happened.

Reference: [Motion — Accessibility - HIG](https://developer.apple.com/design/human-interface-guidelines/motion#Accessibility), WWDC 2023 "Animate with springs"
