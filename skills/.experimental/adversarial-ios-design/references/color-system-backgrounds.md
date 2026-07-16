---
title: Use system background colors for screen surfaces
tags: color, dark-mode, backgrounds, semantic-colors
---

## Use system background colors for screen surfaces

The wrong default for a screen surface is `Color.white`, `Color.black`, or a brand fill painted across the root. A hardcoded surface freezes one appearance: it defeats the base/elevated depth distinction Dark Mode uses to separate layered contexts, breaks the automatic adaptation Liquid Glass and multitasking rely on, and makes every sheet and popover presented over it look detached. The system families carry all of that for free — `Color(.systemBackground)` / `.secondarySystemBackground` for plain hierarchies, and the `systemGroupedBackground` set when the screen is a grouped list or form.

**Evidence of violation:** `Color.white`, `Color.black`, or a named brand color applied as the surface of a root view, a `List`/`ScrollView`/`Form` background (`.background`, `.scrollContentBackground(.hidden)` plus a replacement fill), or a full-screen `ZStack` base layer; a grouped list restyled onto the plain background family or vice versa. PASS: `Color(.systemBackground)` / `Color(.systemGroupedBackground)` families matched to the hierarchy style, or SwiftUI defaults left untouched. N/A: deliberately appearance-invariant immersive surfaces — a video player, photo viewer, camera, or a dark dashboard canvas whose invariance is citable from the code or an adjacent design comment; absent that evidence, fail closed. N/A: the target adds no screen-level backgrounds.

**Incorrect (hardcoded white surface loses Dark Mode's base and elevated layers):**

```swift
import SwiftUI

struct StopBoardView: View {
    let stops: [TransitStop]

    var body: some View {
        List(stops) { stop in
            StopRow(stop: stop)
        }
        .scrollContentBackground(.hidden)
        .background(Color.white) // ⚠️ frozen surface — identical in Dark Mode, sheets no longer read as elevated
        .navigationTitle("Departures")
    }
}
```

**Correct (the grouped system family adapts per appearance and elevation):**

```swift
import SwiftUI

struct StopBoardView: View {
    let stops: [TransitStop]

    var body: some View {
        List(stops) { stop in
            StopRow(stop: stop)
        }
        .navigationTitle("Departures")
        // Grouped lists already sit on Color(.systemGroupedBackground);
        // leaving the default is the correct move.
    }
}

struct RouteCanvasView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            RouteMapLayer()
        }
    }
}
```

Reference: [Human Interface Guidelines — Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode), [Human Interface Guidelines — Color](https://developer.apple.com/design/human-interface-guidelines/color)
