---
title: Give every tappable element a 44-point hit target and clearance
tags: layout, touch-targets, hit-area, spacing
---

## Give every tappable element a 44-point hit target and clearance

The wrong default is sizing a control to its glyph — a 24-point icon button, a hairline stepper, a row of tightly packed symbols. The visual can stay small, but the hit region must not: fingers miss targets under 44×44 points, and misses compound when neighboring controls sit close enough to steal the tap. Give the glyph breathing room with `.padding` and extend the tappable region with `.contentShape`, and keep explicit spacing between adjacent controls at 12 points or more (24 for borderless controls).

**Evidence of violation:** a tappable element — a `Button`, a view carrying `.onTapGesture`, or a custom gesture-driven control — with an explicit `.frame(width:height:)` where either dimension is below 44 and no `.padding` plus `.contentShape` on the same chain whose arithmetic brings the hit region to at least 44; any tappable frame below 28×28 is a violation regardless of claimed expansion (28×28 is Apple's absolute minimum for a control's visible size, not its hit region). Second leg: an explicit `spacing:` literal below 12 on a stack whose adjacent children are two or more interactive controls; the floor rises to 24 when the controls are borderless — treat a control as bezeled only when a `.buttonStyle(.bordered)` / `.buttonStyle(.borderedProminent)` / `.buttonStyle(.glass)` modifier or a `Form`/`List` row container is citable on it; absent that citation, apply the 24-point floor. Both legs judge explicit literals only. PASS: explicit frames at 44 or larger; small glyphs whose `.padding(n)` arithmetic reaches 44 with `.contentShape(Rectangle())` cited; standard system controls left at their default size with no explicit frame. N/A: no explicit frames or spacing literals on interactive elements in the target.

**Incorrect (a 24-point hit target next to a 24-point neighbor invites mis-taps):**

```swift
import SwiftUI

struct EpisodeToolbar: View {
    let episode: Episode
    @Environment(PlaybackModel.self) private var playback

    var body: some View {
        // ⚠️ spacing: 4 packs two sub-28pt targets against each other
        HStack(spacing: 4) {
            Button {
                playback.skipBackward()
            } label: {
                Image(systemName: "gobackward.15")
            }
            .frame(width: 24, height: 24) // ⚠️ hit target far below 44×44

            Button {
                playback.skipForward()
            } label: {
                Image(systemName: "goforward.30")
            }
            .frame(width: 24, height: 24)
        }
    }
}
```

**Correct (small glyphs, full-size tap regions, clear separation):**

```swift
import SwiftUI

struct EpisodeToolbar: View {
    let episode: Episode
    @Environment(PlaybackModel.self) private var playback

    var body: some View {
        HStack(spacing: 24) {
            Button {
                playback.skipBackward()
            } label: {
                Image(systemName: "gobackward.15")
                    .padding(12)
                    .contentShape(Rectangle())
            }

            Button {
                playback.skipForward()
            } label: {
                Image(systemName: "goforward.30")
                    .padding(12)
                    .contentShape(Rectangle())
            }
        }
    }
}
```

Reference: [Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
