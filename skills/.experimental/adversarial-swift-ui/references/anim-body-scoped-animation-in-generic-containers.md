---
title: Animate generic container attributes with the body-scoped animation form
tags: anim, animation, generic-containers, swiftui
---

## Animate generic container attributes with the body-scoped animation form

The wrong default is applying value-based `.animation(_:value:)` to a generic container's modifier chain — the chain that includes the caller-supplied content. A value-based animation modifier is inherited by every view in the subtree it wraps, so every animatable attribute inside the arbitrary `@ViewBuilder` content that responds to the same state change animates too, producing accidental motion the container author cannot see or test for. The `animation(_:body:)` form (iOS 17) guarantees that only the attributes applied within its closure participate in the animation, independent of whatever content the caller passes in.

**Evidence of violation:** a `View` type generic over its content (a `Content: View` type parameter or any caller-supplied `@ViewBuilder` closure) whose body applies `.animation(_:value:)` on a modifier chain that includes the caller-supplied content, or that mutates its own state inside `withAnimation` such that the caller-supplied content participates in the resulting animation. PASS: the container animates its own attributes inside `animation(_:body:)`, leaving the caller's content outside the animated attribute set. `.animation(_:value:)` on a subtree the component fully owns (no generic content) is explicitly endorsed by the source and passes. N/A: the target has no generic containers that animate, or the deployment target is below iOS 17/macOS 14 (the `animation(_:body:)` floor) — version-gated, not FAIL. A carve-out asserted without citable evidence fails closed.

**Incorrect (every animatable attribute in the caller's content inherits the animation):**

```swift
import SwiftUI

struct LockableContentCard<Content: View>: View {
    var isUnlocked: Bool
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding()
            .background(.secondary)
            .opacity(isUnlocked ? 1 : 0.4)
            .animation(.default, value: isUnlocked)
    }
}
```

If the content passed into `LockableContentCard` also depends on the same lock state — swapping a label, resizing a chart — those changes animate as well, whether or not the caller wanted them to.

**Correct (only the container's own opacity animates, regardless of what the caller passes):**

```swift
import SwiftUI

struct LockableContentCard<Content: View>: View {
    var isUnlocked: Bool
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding()
            .background(.secondary)
            .animation(.default) {
                $0.opacity(isUnlocked ? 1 : 0.4)
            }
    }
}
```
