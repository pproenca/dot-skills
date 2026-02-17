---
title: Use matchedGeometryEffect for Contextual Origin Transitions
impact: HIGH
impactDescription: appearing elements feel teleported without a spatial origin — matchedGeometryEffect provides continuous visual tracking that reduces disorientation
tags: refined, matched-geometry, animation, edson-prototype, rams-3, spatial-continuity
---

## Use matchedGeometryEffect for Contextual Origin Transitions

The difference is visceral: a mini-player that morphs into a full player — you watch the transformation happen, one object becoming another — versus one view disappearing and another appearing, a jump cut that breaks spatial continuity. The morph tells your brain "this is the same thing, just bigger." The jump cut forces your brain to reconnect two unrelated frames. `matchedGeometryEffect` tells SwiftUI that two views are the same object, and the framework interpolates position, size, and corner radius automatically to maintain that physical continuity.

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

**Exceptional (the creative leap) — multi-element choreographed morph:**

```swift
struct NowPlayingView: View {
    @Namespace private var ns
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Spacer()
            if isExpanded {
                ExpandedPlayer(ns: ns)
                    .onTapGesture { isExpanded = false }
            } else {
                MiniBar(ns: ns)
                    .onTapGesture { isExpanded = true }
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.2), value: isExpanded)
    }
}

struct MiniBar: View {
    var ns: Namespace.ID
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6).fill(.secondary)
                .frame(width: 44, height: 44)
                .matchedGeometryEffect(id: "artwork", in: ns)
            Text("Song Title").font(.subheadline.weight(.medium))
                .matchedGeometryEffect(id: "title", in: ns)
            Spacer()
            Image(systemName: "play.fill")
                .matchedGeometryEffect(id: "action", in: ns)
        }
        .padding(.horizontal).padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ExpandedPlayer: View {
    var ns: Namespace.ID
    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 16).fill(.secondary)
                .frame(width: 280, height: 280)
                .matchedGeometryEffect(id: "artwork", in: ns)
            Text("Song Title").font(.title2.weight(.semibold))
                .matchedGeometryEffect(id: "title", in: ns)
            Image(systemName: "pause.fill").font(.title)
                .matchedGeometryEffect(id: "action", in: ns)
        }.padding(32)
    }
}
```

When each element carries its own matched ID, SwiftUI interpolates them independently -- the artwork grows and rounds its corners, the title drifts from beside the artwork to beneath it, and the play button slides to center while morphing from play to pause. The eye doesn't track one transition; it experiences a constellation of movements that resolve together, the way every instrument in an orchestra lands on the downbeat at the same instant. That convergence is what makes it feel like one object unfolding rather than two views swapping.

**Tips for clean matched geometry transitions:**
- Match the **outermost container** first; match sub-elements (artwork, title) with separate IDs for richer morphs
- Use `isSource: true` on the view that should define the resting geometry when both are visible simultaneously
- Combine with `.transition(.opacity)` on child content that should fade rather than morph (e.g., playback controls)
- Keep both states in the same `ZStack` or `VStack` to avoid layout jumps during the transition

**When NOT to apply:** Simple show/hide toggles where the two states share no visual identity (e.g., a toast notification appearing at the top of the screen), and navigation transitions already handled by `NavigationStack` or `.navigationTransition(.zoom)` which provide their own spatial continuity.

**Reference:** Apple Music (mini-player to full player), Photos (thumbnail to full image), WWDC 2021 session on `matchedGeometryEffect`.
