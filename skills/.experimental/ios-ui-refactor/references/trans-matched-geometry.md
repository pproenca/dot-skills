---
title: Use matchedGeometryEffect for Contextual Origin Transitions
impact: HIGH
impactDescription: Without a spatial origin, appearing elements feel teleported — matchedGeometryEffect provides continuous visual tracking that reduces user disorientation by anchoring transitions to a physical source
tags: trans, matched-geometry, animation, spatial-continuity, morph
---

## Use matchedGeometryEffect for Contextual Origin Transitions

When a compact element expands into a larger view (a mini-player becoming a full-screen player, a card expanding into a detail pane), the user needs to see that the two states are the same object. Without a shared geometric origin, the expansion feels like one view disappearing and another appearing from nowhere. `matchedGeometryEffect` tells SwiftUI that two views share an identity, and the framework automatically interpolates position, size, and corner radius between them — the same technique Apple Music uses for its mini-player-to-full-player transition.

**Incorrect (abrupt swap between compact and expanded states):**

```swift
struct NowPlayingView: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Spacer()

            if isExpanded {
                // Full player appears from nowhere — no spatial link
                // to the mini bar the user just tapped
                FullPlayerView()
                    .transition(.move(edge: .bottom))
            } else {
                MiniPlayerBar()
                    .onTapGesture { isExpanded = true }
            }
        }
        .animation(.smooth, value: isExpanded)
    }
}
```

**Correct (matched geometry morphs between compact and expanded):**

```swift
struct NowPlayingView: View {
    @Namespace private var playerNamespace
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Spacer()

            if isExpanded {
                FullPlayerView()
                    // Share identity with the mini bar's artwork
                    .matchedGeometryEffect(id: "player", in: playerNamespace)
                    .onTapGesture { isExpanded = false }
            } else {
                MiniPlayerBar()
                    // Same id + namespace = SwiftUI interpolates between them
                    .matchedGeometryEffect(id: "player", in: playerNamespace)
                    .onTapGesture { isExpanded = true }
            }
        }
        .animation(.smooth, value: isExpanded)
    }
}

struct MiniPlayerBar: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondary)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading) {
                Text("Song Title").font(.subheadline).fontWeight(.medium)
                Text("Artist").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "play.fill")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Tips for clean matched geometry transitions:**
- Match the **outermost container** first; match sub-elements (artwork, title) with separate IDs for richer morphs
- Use `isSource: true` on the view that should define the resting geometry when both are visible simultaneously
- Combine with `.transition(.opacity)` on child content that should fade rather than morph (e.g., playback controls)
- Keep both states in the same `ZStack` or `VStack` to avoid layout jumps during the transition

**Reference:** Apple Music (mini-player to full player), Photos (thumbnail to full image), WWDC 2021 session on `matchedGeometryEffect`.
