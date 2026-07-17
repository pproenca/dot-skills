---
title: Remove animation that decorates instead of communicates
tags: motion, restraint, repeatforever, decoration, gratuitous
---

## Remove animation that decorates instead of communicates

The wrong default when asked to "polish" or "add delight" to a screen is ambient
animation — pulsing icons, floating cards, staggered entrance cascades, parallax on
static content. The HIG's position is that motion communicates: it provides feedback,
teaches cause and effect, and connects a change to the action that caused it. Motion
that no user action caused communicates nothing; it competes with content for
attention, and a `.repeatForever()` loop keeps the render loop hot on every frame for
as long as the screen is visible. This is the one rule in this category whose fix
deletes code: remove the loop — do not guard it, slow it down, or make it subtler.

**Evidence of violation:** an idle filmstrip (a recording of the screen at rest, no
input) in which content moves — pulses, floats, shimmers, rotates, or shifts in
parallax — where the moving element is not an indeterminate-progress indicator or
loading skeleton; or an interaction filmstrip in which elements unrelated to the
user's change animate as decoration, such as an entrance cascade staggering static
content onto the screen on plain appearance. Cite the tiles and the animating element.
Code candidates when no recording covers the screen: a `.repeatForever()` driving a
non-progress element, an `.onAppear` whose only effect is animating static content
into place outside onboarding or celebration, a `TimelineView` or `.phaseAnimator`
driving decoration on non-playful content — report each as N/A with the reason
"recording evidence unavailable — candidate at file:line", never FAIL from code alone.
PASS: idle filmstrips are static apart from progress indicators, and interaction
filmstrips move only what the interaction changed — cite the idle captures checked.
N/A: no idle recording exists and the code contains none of the candidate patterns.
Carve-outs (must be cited): indeterminate progress and skeleton shimmer are progress
placeholders, not decoration; a persistent status indicator whose motion signals an
ongoing process the user started — a recording badge, a live-broadcast dot, an active
timer — the reviewer must cite the process it reflects; a celebration or onboarding
moment the target's own design frames as playful; a brand launch moment. Absent that
citation, fail closed.
A Reduce Motion guard does not excuse decoration — `motion-reduce-motion-path` judges
the guard, this rule judges whether the loop should exist at all.

**Incorrect (the balance header floats forever — motion no user caused, burning frames to say nothing):**

```swift
import SwiftUI

struct PortfolioHeader: View {
    let balance: Decimal
    @State private var isFloating = false

    var body: some View {
        VStack(spacing: 8) {
            Text(balance, format: .currency(code: "USD"))
                .font(.largeTitle.bold())
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .offset(y: isFloating ? -6 : 6)
        }
        .onAppear {
            // ⚠️ Nothing changed and nothing is loading — the float is pure decoration
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}
```

**Correct (the header is still; motion is reserved for the moment the balance actually changes):**

```swift
import SwiftUI

struct PortfolioHeader: View {
    let balance: Decimal

    var body: some View {
        VStack(spacing: 8) {
            Text(balance, format: .currency(code: "USD"))
                .font(.largeTitle.bold())
                .contentTransition(.numericText())
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
        }
    }
}
```

Reference: [Human Interface Guidelines — Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
