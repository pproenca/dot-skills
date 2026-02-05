---
title: Use Spring Animations as Default
impact: MEDIUM-HIGH
impactDescription: creates natural, iOS-native motion feel
tags: anim, spring, animation, motion, physics
---

## Use Spring Animations as Default

Spring animations are the iOS default. They feel natural because they simulate physical motion. Use them instead of linear or easeIn/Out.

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
            withAnimation(.easeInOut(duration: 0.3)) {  // Mechanical feel
                isExpanded.toggle()
            }
        }
    }
}
```

**Correct (spring physics):**

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
            withAnimation(.spring()) {  // Natural, bouncy feel
                isExpanded.toggle()
            }
        }
    }
}
```

**Spring presets:**

```swift
.spring()        // Default, balanced (response: 0.5, dampingFraction: 0.825)
.smooth          // No bounce, smooth settle
.snappy          // Quick, minimal bounce
.bouncy          // Playful, noticeable bounce

// Custom spring
.spring(response: 0.3, dampingFraction: 0.6)
// response: duration-like (lower = faster)
// dampingFraction: 0 = infinite bounce, 1 = no bounce
```

**When to use each:**

| Animation | Use Case |
|-----------|----------|
| .spring() | General UI transitions |
| .smooth | Scroll position, subtle changes |
| .snappy | Button feedback, quick actions |
| .bouncy | Fun interactions, achievements |
| .easeOut | One-way exits (dismiss, fade out) |

**Implicit animation:**

```swift
Circle()
    .frame(width: isLarge ? 100 : 50)
    .animation(.spring(), value: isLarge)  // Animates when isLarge changes
```

Reference: [WWDC23: Animate with Springs](https://developer.apple.com/videos/play/wwdc2023/10158/)
