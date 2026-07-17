---
title: Use springs for movement instead of ease curves
tags: motion, springs, easing, animation-curves
---

## Use springs for movement instead of ease curves

The wrong default is `.easeInOut(duration: 0.3)` (or `.linear`) sprinkled on every animation — the pre-2023 idiom. Ease curves have zero velocity at both ends, so an animation that begins from a gesture jerks to a halt at handoff and any retarget mid-flight snaps; Apple's own guidance is that springs are the only animation that maintains continuity both for static starts and starts with initial velocity, which is why the SwiftUI default animation has been a spring since iOS 17. Movement and layout changes get springs; ease curves survive only where nothing physically moves.

**Evidence of violation:** `.linear`, `.easeIn`, `.easeOut`, or `.easeInOut` (with or without `duration:`) applied to an animation that moves or resizes a view — offset, position, frame, scale, insertion/removal transition, or a drag settle. Cite the animation expression. PASS: `withAnimation { … }` with no argument (the default is a spring on iOS 17+), or `.default`, `.smooth`, `.snappy`, `.bouncy`, `.spring(…)`, `.interpolatingSpring(…)` — cite the call site. N/A-style carve-outs (must be cited): `.linear` driving constant-rate non-interactive motion such as an indeterminate progress rotation, a marquee, or a shimmer sweep; an ease curve on a pure opacity crossfade where no geometry changes — the reviewer must cite that the animated property is exclusively opacity or constant-rate decorative motion; absent that evidence, fail closed. N/A: the target contains no explicit animation curves at all. This rule stays decidable from code without a recording: the curve expression deterministically produces the motion character, the jerk it causes shows only under mid-flight interruption a filmstrip rarely captures, and the fix swaps a curve for a spring at the cited call site — it never adds animation.

**Incorrect (the bid card's expansion jerks to a stop and fights the gesture that opened it):**

```swift
import SwiftUI

struct BidCard: View {
    let itemName: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(itemName).font(.headline)
            if isExpanded {
                Text("Current bid history and reserve details")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: .rect(cornerRadius: 12))
        .onTapGesture {
            // ⚠️ Ease curve on a layout change — zero end velocity, snaps on retarget
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
}
```

**Correct (a spring keeps velocity continuous through interruption and retargeting):**

```swift
import SwiftUI

struct BidCard: View {
    let itemName: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(itemName).font(.headline)
            if isExpanded {
                Text("Current bid history and reserve details")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: .rect(cornerRadius: 12))
        .onTapGesture {
            withAnimation(.snappy) {
                isExpanded.toggle()
            }
        }
    }
}
```

Reference: [WWDC23 — Animate with springs](https://developer.apple.com/videos/play/wwdc2023/10158/), [Animation.default](https://developer.apple.com/documentation/swiftui/animation/default)
