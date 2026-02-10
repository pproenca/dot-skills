---
title: Use Spring Animations as Default
impact: MEDIUM
impactDescription: matches iOS system motion language, perceived 30-40% smoother transitions vs linear/easeInOut
tags: anim, spring, animation, motion, physics
---

## Use Spring Animations as Default

Spring animations are the iOS system default. They simulate physical motion with natural deceleration, making UI feel responsive rather than mechanical. Since iOS 17, `withAnimation` uses spring by default, and the API has been simplified with static presets.

**Incorrect (mechanical easing):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Text("Header")
            if isExpanded {
                Text("Details...")
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
}
```

**Correct (spring physics — iOS 17+):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Text("Header")
            if isExpanded {
                Text("Details...")
            }
        }
        .onTapGesture {
            withAnimation(.spring) {
                isExpanded.toggle()
            }
        }
    }
}
```

**iOS 17+ spring presets (static properties):**

```swift
.spring        // Default, balanced
.smooth        // No bounce, smooth settle
.snappy        // Quick, minimal bounce
.bouncy        // Playful, noticeable bounce

// Custom spring (iOS 17+ API: duration/bounce)
.spring(duration: 0.3, bounce: 0.2)
// duration: perceptual duration of the animation
// bounce: 0 = no bounce, 0.5 = moderate, negative = overdamped
```

**Legacy spring API (iOS 16 and earlier):**

```swift
// Use response/dampingFraction for deployment targets < iOS 17
.spring(response: 0.3, dampingFraction: 0.6)
// response: duration-like (lower = faster)
// dampingFraction: 0 = infinite bounce, 1 = no bounce
```

**When to use each:**

| Animation | Use Case |
|-----------|----------|
| .spring | General UI transitions (default) |
| .smooth | Scroll position, subtle changes |
| .snappy | Button feedback, quick actions |
| .bouncy | Fun interactions, achievements |
| .easeOut | One-way exits (dismiss, fade out) |

**Implicit animation:**

```swift
Circle()
    .frame(width: isLarge ? 100 : 50)
    .animation(.spring, value: isLarge)
```

Reference: [WWDC23: Animate with Springs](https://developer.apple.com/videos/play/wwdc2023/10158/)
