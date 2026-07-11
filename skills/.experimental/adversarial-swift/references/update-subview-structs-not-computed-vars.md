---
title: Extract view chunks into standalone structs not computed properties
tags: update, view-composition, viewbuilder, dependency-tracking
---

## Extract view chunks into standalone structs not computed properties

The wrong default is breaking a large `body` into private `@ViewBuilder` computed properties or `func ... -> some View` helpers on the same view. These read cleaner but are not independent nodes in the view tree — they are part of the parent view's own identity, with no independent dependency tracking, so SwiftUI is forced to re-execute their logic on every parent invalidation. A standalone view struct defines a boundary in the attribute graph: if its input data has not changed, SwiftUI skips its body entirely.

**Evidence of violation:** a private computed property or method returning `some View` (with or without `@ViewBuilder`) whose body performs work beyond composing already-stored values — a data lookup, format call, filter, sort, or provider call — declared inside a view that has other changing dependencies (`@State`, `@Environment`, `@Binding`, or observable reads). PASS: the same chunk lives in a standalone `struct X: View` receiving only the data it needs. N/A: helper properties that merely group static literal subviews with no computation, or the parent has no dynamic dependencies. PASS is also granted when a comment cites a measured reason the extraction is unnecessary — an uncited claim fails closed. Precedence when a computed member returns `some View` and also contains an O(n) transform: report this rule (extract the subview); `update-cache-expensive-derivations` applies only to transforms that would survive the extraction.

**Incorrect (the lookup re-runs whenever anything in the parent changes):**

```swift
import SwiftUI

struct TrailDetailView: View {
    let regionID: UUID
    @State private var isBookmarked = false

    @ViewBuilder
    private var regionSection: some View {
        if let name = RegionDirectory.name(for: regionID) {
            Text("Region: \(name)")
        }
    }

    var body: some View {
        VStack {
            regionSection
            Toggle("Bookmark", isOn: $isBookmarked)
        }
    }
}

enum RegionDirectory {
    static func name(for id: UUID) -> String? { nil /* directory search */ }
}
```

**Correct (the lookup is skipped while regionID is unchanged):**

```swift
import SwiftUI

struct RegionSection: View {
    let regionID: UUID

    var body: some View {
        if let name = RegionDirectory.name(for: regionID) {
            Text("Region: \(name)")
        }
    }
}

struct TrailDetailView: View {
    let regionID: UUID
    @State private var isBookmarked = false

    var body: some View {
        VStack {
            RegionSection(regionID: regionID)
            Toggle("Bookmark", isOn: $isBookmarked)
        }
    }
}

enum RegionDirectory {
    static func name(for id: UUID) -> String? { nil /* directory search */ }
}
```

Reference: expert SwiftUI reference (2026), “Defining focused view components”.
