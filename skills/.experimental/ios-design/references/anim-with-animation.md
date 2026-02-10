---
title: Use withAnimation for Explicit State-Driven Animations
impact: MEDIUM
impactDescription: "controls exactly which state changes animate vs instant; prevents unintended 200-400ms transitions"
tags: anim, withAnimation, animation, state, explicit
---

## Use withAnimation for Explicit State-Driven Animations

Use `withAnimation` to explicitly animate state changes. Avoid `.animation()` on views, which can animate unrelated changes.

**Incorrect (.animation on view animates everything):**

```swift
struct FilterView: View {
    @State private var isExpanded = false
    @State private var filterCount = 0

    var body: some View {
        VStack {
            Button("Filters (\(filterCount))") {
                isExpanded.toggle()
            }
            if isExpanded {
                FilterOptions(count: $filterCount)
            }
        }
        .animation(.spring(), value: isExpanded)
        // Also animates filterCount text changes unintentionally
    }
}
```

**Correct (withAnimation targets specific changes):**

```swift
struct FilterView: View {
    @State private var isExpanded = false
    @State private var filterCount = 0

    var body: some View {
        VStack {
            Button("Filters (\(filterCount))") {
                withAnimation(.spring()) {
                    isExpanded.toggle() // Only this change animates
                }
            }
            if isExpanded {
                FilterOptions(count: $filterCount)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
```

**Spring animation presets:**

```swift
withAnimation(.spring()) { }                    // Default spring
withAnimation(.spring(duration: 0.3)) { }       // Quick spring
withAnimation(.spring(bounce: 0.3)) { }         // Bouncy spring
withAnimation(.easeInOut(duration: 0.25)) { }   // Standard ease
withAnimation(.interactiveSpring) { }            // For drag gestures
```

Reference: [Animations - Apple Documentation](https://developer.apple.com/documentation/swiftui/animation)
