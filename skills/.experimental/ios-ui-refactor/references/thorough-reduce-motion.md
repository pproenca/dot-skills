---
title: Always Provide Reduce Motion Fallback
impact: HIGH
impactDescription: required for accessibility compliance; 10-15% of users enable Reduce Motion due to vestibular disorders, and missing fallbacks can cause nausea or disorientation
tags: thorough, motion, accessibility, rams-8, rams-2, reduce-motion
---

## Always Provide Reduce Motion Fallback

Rams' #8 demanded nothing be left to chance. A user with a vestibular disorder enabling Reduce Motion is not a chance occurrence — it is a certainty. Rams' #2 insisted products be useful to all users, not just the majority. Missing a motion fallback means the product fails to be useful for 10-15% of your audience.

**Incorrect (custom animations with no Reduce Motion check):**

```swift
struct OnboardingCard: View {
    @State private var isVisible = false

    var body: some View {
        VStack {
            // Slides in and bounces regardless of accessibility setting
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

**Reusable helper for consistent Reduce Motion handling:**

```swift
extension Animation {
    /// Return the animation or a quick crossfade when Reduce Motion is on.
    static func adaptive(
        _ animation: Animation,
        reduceMotion: Bool
    ) -> Animation {
        reduceMotion ? .smooth(duration: 0.1) : animation
    }
}

// Usage
.animation(
    .adaptive(.bouncy, reduceMotion: reduceMotion),
    value: isVisible
)
```

**What to reduce, not remove:** Replace spatial movement (slides, bounces, zooms) with opacity crossfades. Keep opacity transitions short (under 150ms). Never remove the state change entirely; the user still needs to see that something happened.

**Reference:** Apple HIG "Motion — Accessibility"; WWDC 2023 "Animate with springs" — Apple states that spring animations should still respect Reduce Motion by falling back to crossfade or instant transitions.
