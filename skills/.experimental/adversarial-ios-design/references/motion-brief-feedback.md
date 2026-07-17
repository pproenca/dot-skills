---
title: Keep direct-interaction feedback under half a second
tags: motion, duration, feedback, responsiveness
---

## Keep direct-interaction feedback under half a second

The wrong default is hardcoding slow durations — `duration: 0.8`, `1.0` — on small element responses to taps, toggles, and selections, making every interaction feel syrupy. The HIG asks for brevity and precision in feedback animations (brief, precise motion feels lightweight and unobtrusive) and warns against making people wait for an animation to complete before they can do anything. The 0.5-second ceiling this rule enforces is a derived threshold, not an Apple-published number: it is anchored to Apple's own default spring (response 0.55) and the HIG's brevity language — anything explicitly slower than the system's default feel on a direct interaction needs a reason.

**Evidence of violation:** a filmstrip in which feedback for a direct interaction — a button tap response, toggle, selection highlight, row expansion, or small element move — spans more than 5 tiles at 10 fps (more than 0.5 s from the input frame to the settled frame), corroborated by the explicit `duration:` or `response:` literal greater than 0.5 in code. Cite the tile count, the literal, and the interaction it responds to. When no recording covers the interaction, the over-cap literal is a **candidate** — report it as N/A with the reason "recording evidence unavailable — candidate at file:line", never FAIL from the literal alone. PASS: the filmstrip settles within 5 tiles, or the code has no explicit duration (system default) or literals at or below 0.5 on interaction feedback — cite the tiles or the call sites checked. N/A: the slow motion drives a full-screen or hero transition, or a deliberate onboarding/celebration moment — the reviewer must cite the full-screen or celebratory nature of the animated content; absent that evidence, fail closed. N/A: no explicit duration or response literals exist in the target and no filmstrip shows over-long interaction feedback. The fix is lowering the cited literal or dropping it for the system default — it never adds animation.

**Incorrect (a one-second favorite toggle makes the app feel unresponsive):**

```swift
import SwiftUI

struct EpisodeRow: View {
    let title: String
    @State private var isFavorite = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button {
                // ⚠️ 1.0s response to a tap — the user waits on a star
                withAnimation(.spring(duration: 1.0)) {
                    isFavorite.toggle()
                }
            } label: {
                Label("Favorite", systemImage: isFavorite ? "star.fill" : "star")
                    .labelStyle(.iconOnly)
                    .scaleEffect(isFavorite ? 1.2 : 1)
            }
        }
    }
}
```

**Correct (default spring timing keeps the response snappy):**

```swift
import SwiftUI

struct EpisodeRow: View {
    let title: String
    @State private var isFavorite = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button {
                withAnimation(.snappy) {
                    isFavorite.toggle()
                }
            } label: {
                Label("Favorite", systemImage: isFavorite ? "star.fill" : "star")
                    .labelStyle(.iconOnly)
                    .scaleEffect(isFavorite ? 1.2 : 1)
            }
        }
    }
}
```

Reference: [Human Interface Guidelines — Motion](https://developer.apple.com/design/human-interface-guidelines/motion), [Animation.default](https://developer.apple.com/documentation/swiftui/animation/default)
