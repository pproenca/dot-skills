---
title: Use Modern Spring Animation Syntax (iOS 17+)
impact: MEDIUM-HIGH
impactDescription: clearer intent, automatic velocity matching
tags: anim, spring, duration, bounce, ios17
---

## Use Modern Spring Animation Syntax (iOS 17+)

iOS 17 introduced a simplified spring API that uses `duration` and `bounce` instead of physics parameters like `response`, `dampingFraction`, and `blendDuration`. The new syntax expresses design intent directly -- how long the animation should feel and how bouncy it should be. SwiftUI's built-in navigation transitions already use non-bouncy springs, so matching this convention for custom animations creates a cohesive feel throughout the app.

**Incorrect (legacy spring parameters):**

```swift
// BAD: response/dampingFraction/blendDuration are physics terms that
// don't communicate design intent. Designers can't reason about what
// dampingFraction: 0.7 looks like, and blendDuration is almost always 0.
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            CardHeader()
                .onTapGesture {
                    withAnimation(
                        .spring(
                            response: 0.5,
                            dampingFraction: 0.7,
                            blendDuration: 0
                        )
                    ) {
                        isExpanded.toggle()
                    }
                }

            if isExpanded {
                CardContent()
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
            }
        }
    }
}
```

**Correct (modern duration/bounce spring syntax):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            CardHeader()
                .onTapGesture {
                    // duration: perceived settling time
                    // bounce: 0 = no overshoot (navigation-like),
                    //         0.3 = subtle bounce, negative = overdamped
                    withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                        isExpanded.toggle()
                    }
                }

            if isExpanded {
                CardContent()
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
            }
        }
        // For navigation-matching animations, use zero bounce:
        // .spring(duration: 0.4, bounce: 0)
        //
        // For playful interactions:
        // .spring(duration: 0.5, bounce: 0.3)
        //
        // Presets also available:
        // .smooth         -> duration: 0.5, bounce: 0
        // .snappy         -> duration: 0.5, bounce: 0.15
        // .bouncy         -> duration: 0.5, bounce: 0.3
    }
}
```
