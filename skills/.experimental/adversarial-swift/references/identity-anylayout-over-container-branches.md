---
title: Switch layouts with AnyLayout instead of branching between containers
tags: identity, anylayout, adaptive-layout, size-class
---

## Switch layouts with AnyLayout instead of branching between containers

The wrong default is `if sizeClass == .regular { HStack { content } } else { VStack { content } }` with identical children in both branches. The branch replaces the entire view tree on every size-class or orientation change, so the children lose their structural identity and internal state — image loading progress, scroll positions — is wiped. With `AnyLayout`, the container changes its layout behavior while the subviews keep a stable position in the hierarchy, giving a smooth layout transition instead of a full replacement.

**Evidence of violation:** an `if/else` on a state or environment value that switches between two layout container types (`HStack`/`VStack`/`Grid` and similar) wrapping the same children. PASS: an `AnyLayout(HStackLayout())` / `AnyLayout(VStackLayout())` value selected by ternary and applied to one stable child list. N/A: the branches contain different children (a genuine structural change), or the deployment target is below iOS 16/macOS 13, where `AnyLayout` is unavailable.

**Incorrect (size-class change replaces the whole subtree):**

```swift
import SwiftUI

struct FeaturedTrailsView: View {
    let trailNames: [String]

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            HStack {
                ForEach(trailNames, id: \.self) { Text($0) }
            }
        } else {
            VStack {
                ForEach(trailNames, id: \.self) { Text($0) }
            }
        }
    }
}
```

**Correct (children keep identity across layout changes):**

```swift
import SwiftUI

struct FeaturedTrailsView: View {
    let trailNames: [String]

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    private var layout: AnyLayout {
        horizontalSizeClass == .regular
            ? AnyLayout(HStackLayout())
            : AnyLayout(VStackLayout())
    }

    var body: some View {
        layout {
            ForEach(trailNames, id: \.self) { Text($0) }
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Preserving structural view identity”.
