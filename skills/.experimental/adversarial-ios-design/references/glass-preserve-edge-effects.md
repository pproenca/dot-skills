---
title: Never paint behind bars or stack scroll edge effects
tags: glass, scroll-edge, toolbars, liquid-glass
---

## Never paint behind bars or stack scroll edge effects

The wrong default is pre-iOS 26 muscle memory: `.toolbarBackground(brandColor, for: .navigationBar)`, a darkening gradient tucked under the bar, an opaque fill behind a hand-pinned header. Under Liquid Glass the system already keeps bar items legible with an automatic scroll edge effect — a subtle blur and fade applied to content passing beneath floating UI. Custom paint sits on top of that machinery and defeats it, and the effect's two styles are exclusive by design: soft and hard must not be mixed or stacked, and the effect exists only to mark where floating UI meets content — never as decoration.

**Evidence of violation:** (a) `.toolbarBackground(` with a color or opaque style, `UINavigationBarAppearance`/`UITabBarAppearance` with an assigned `backgroundColor`, or a custom fill/gradient/shadow layer rendered behind system bar items over scrolling content — cite the modifier site; (b) `.scrollEdgeEffectStyle(.soft, …)` and `.scrollEdgeEffectStyle(.hard, …)` applied to overlapping regions of the same view, or duplicate effects stacked on one boundary; (c) an edge effect applied to a boundary where no floating UI overlaps the scroll view; (d) a custom pinned accessory floating over scroll content whose automatic effect is disabled and replaced with painted background. PASS: system bars left with default backgrounds; one edge effect per boundary; custom pinned accessories registered for a scroll edge effect rather than painted — cite the configuration. N/A: the target's minimum deployment is below iOS 26 (the scroll edge effect and its API do not exist there).

**Incorrect (brand paint under the bar kills the system's legibility treatment):**

```swift
import SwiftUI

struct GalleryFeedView: View {
    let listings: [ArtListing]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(listings) { ArtworkHeroCard(listing: $0) }
            }
        }
        .navigationTitle("Gallery")
        .toolbarBackground(Color.indigo, for: .navigationBar) // ⚠️ opaque paint replaces the scroll edge effect
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
```

**Correct (default bar; the scroll edge effect handles the boundary):**

```swift
import SwiftUI

struct GalleryFeedView: View {
    let listings: [ArtListing]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(listings) { ArtworkHeroCard(listing: $0) }
            }
        }
        .navigationTitle("Gallery")
        // No bar paint. Content scrolls beneath the glass bar and the
        // automatic scroll edge effect keeps the title and items legible.
    }
}

struct PinnedFilterBar: View {
    var body: some View {
        ScrollView {
            GalleryGrid()
        }
        .safeAreaInset(edge: .top) {
            FilterChipsRow()
        }
        .scrollEdgeEffectStyle(.hard, for: .top) // one deliberate effect at the pinned boundary
    }
}
```

Reference: [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass), [WWDC25 — Get to know the new design system](https://developer.apple.com/videos/play/wwdc2025/356/), [WWDC25 — Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
