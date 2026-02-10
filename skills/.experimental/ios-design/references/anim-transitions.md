---
title: Use Semantic Transitions for Appearing Views
impact: MEDIUM-HIGH
impactDescription: prevents abrupt 0ms insertions, adds 200-400ms contextual animations
tags: anim, transition, appear, disappear, insert, remove
---

## Use Semantic Transitions for Appearing Views

When views are inserted or removed, use `.transition()` to define how they animate. Choose transitions that match the spatial context.

**Incorrect (abrupt insertion):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red)
                // No transition - just pops in
        }
    }
}
```

**Correct (slide from edge):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red)
                .clipShape(.rect(cornerRadius: 8))
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// Trigger with animation
withAnimation(.spring()) {
    showBanner = true
}
```

**Built-in transitions:**

```swift
.transition(.opacity)           // Fade in/out
.transition(.scale)             // Grow/shrink from center
.transition(.slide)             // Slide from leading edge
.transition(.move(edge: .top))  // Slide from specific edge
.transition(.push(from: .trailing))  // Push like navigation

// Combine transitions
.transition(.opacity.combined(with: .scale))
.transition(.asymmetric(insertion: .scale, removal: .opacity))
```

**Common patterns:**

```swift
// Toast notification (from bottom)
.transition(.move(edge: .bottom).combined(with: .opacity))

// Modal overlay
.transition(.opacity)

// Side panel
.transition(.move(edge: .trailing))

// Action sheet items
.transition(.scale.combined(with: .opacity))

// List item
.transition(.slide)
```

**Custom transition:**

```swift
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
```

Reference: [Animations Documentation](https://developer.apple.com/documentation/swiftui/animations)
