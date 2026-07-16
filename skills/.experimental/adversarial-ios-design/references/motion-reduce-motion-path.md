---
title: Provide a Reduce Motion path for large or repeating animations
tags: motion, reduce-motion, accessibility, vestibular
---

## Provide a Reduce Motion path for large or repeating animations

The wrong default is zero `accessibilityReduceMotion` handling anywhere — models never emit it unprompted. Users who enable Reduce Motion do so because zooming, scaling, and peripheral motion can cause genuine discomfort; Apple's guidance is to respond by reducing automatic and repetitive animation, tightening springs to remove bounce, replacing x/y/z-axis transitions with fades, and avoiding animating into and out of blurs. An app whose big custom animations play identically regardless of the setting is overriding a medical accommodation.

**Evidence of violation:** any of these trigger patterns with no `@Environment(\.accessibilityReduceMotion)` (or `UIAccessibility.isReduceMotionEnabled`) branch in the same view or module altering the behavior: a `.repeatForever()` animation; an animated `scaleEffect` or `offset` spanning a container or the full screen; an animated `blur(radius:)`; an animated `rotation3DEffect` or parallax effect; a custom bouncy hero transition. Cite the trigger pattern and the absence of the branch — the absence is the violation, so a trigger with no Reduce Motion handling anywhere is FAIL, not N/A. PASS: the environment value is read and the guarded branch replaces movement with an opacity fade, tightens the spring to remove bounce, or disables the repeat — cite both the read and the branch. N/A: none of the enumerated trigger patterns exist in the target — small, brief, single-shot feedback animations do not trigger this rule.

**Incorrect (a forever-pulsing recording badge ignores the user's Reduce Motion setting):**

```swift
import SwiftUI

struct RecordingBadge: View {
    @State private var isPulsing = false

    var body: some View {
        Label("Recording", systemImage: "record.circle")
            .foregroundStyle(.red)
            .scaleEffect(isPulsing ? 1.3 : 1)
            .onAppear {
                // ⚠️ Repeating scale animation with no accessibilityReduceMotion branch
                withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                    isPulsing = true
                }
            }
    }
}
```

**Correct (Reduce Motion swaps the pulse for a static opacity emphasis):**

```swift
import SwiftUI

struct RecordingBadge: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    var body: some View {
        Label("Recording", systemImage: "record.circle")
            .foregroundStyle(.red)
            .scaleEffect(isPulsing ? 1.3 : 1)
            .opacity(reduceMotion ? 0.85 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                    isPulsing = true
                }
            }
    }
}
```

Reference: [accessibilityReduceMotion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion), [Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
