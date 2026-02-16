---
title: Use Semantic Transitions for Appearing and Disappearing Views
impact: HIGH
impactDescription: abrupt 0ms insertions and removals disorient users — semantic transitions provide 200-400ms of spatial context that communicates where content came from and where it went
tags: product, transition, appear, edson-product-marketing, kocienda-demo, motion
---

## Use Semantic Transitions for Appearing and Disappearing Views

Edson's "the product is the marketing" means every micro-interaction communicates quality. When a banner appears abruptly — popping into existence at full opacity — it signals carelessness. When it slides down from the top with a spring, it communicates spatial context and intention. Kocienda's demo culture meant that every animation had to survive Steve Jobs' scrutiny; a jarring insertion would never pass. The transition you choose tells the user where the content came from and how it relates to the screen.

**Incorrect (abrupt insertion with no spatial context):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.white)
            // Pops into existence — no spatial context
        }
    }
}
```

**Correct (transition communicates spatial origin):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.white)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// Trigger with animation
withAnimation(.smooth) {
    showBanner = true
}
```

**Transition vocabulary:**

```swift
// Fade — for overlays and state changes
.transition(.opacity)

// Scale — for items appearing "from nothing"
.transition(.scale)

// Slide — for content entering from the leading edge
.transition(.slide)

// Move — for content entering from a specific edge
.transition(.move(edge: .top))

// Push — for navigation-like transitions
.transition(.push(from: .trailing))

// Combined — for richer spatial cues
.transition(.move(edge: .bottom).combined(with: .opacity))

// Asymmetric — different enter and exit
.transition(.asymmetric(
    insertion: .push(from: .trailing),
    removal: .push(from: .leading)
))
```

**When NOT to animate:** Content that is always present but conditionally empty (use `ContentUnavailableView` instead). System-managed transitions like `NavigationStack` push/pop already handle their own animations.

Reference: [Animations Documentation - Apple](https://developer.apple.com/documentation/swiftui/animations)
