---
title: Use the Observable macro instead of ObservableObject for new models
tags: state, observation, observable-macro, swiftui
---

## Use the Observable macro instead of ObservableObject for new models

The wrong default is reaching for the legacy `ObservableObject` protocol with `@Published` properties, consumed through `@StateObject`/`@ObservedObject`. When a view reads at least one `@Published` property of an `ObservableObject`, its body re-evaluates when *any* of the `@Published` properties change — even ones the view never reads. The `@Observable` macro tracks dependencies at the property level, so a view re-evaluates only when a property it actually reads is modified, eliminating this over-invalidation across every observer.

**Evidence of violation:** newly written code containing an `ObservableObject` conformance, a `@Published` property, `@StateObject`, or `@ObservedObject`. PASS: models declared with `@Observable` and consumed via `@State`, `@Bindable`, or a plain property. N/A: the deployment target is below iOS 17/macOS 14 (the Observation framework's floor), or a comment cites a concrete interop constraint (e.g. a third-party SDK type that is an `ObservableObject`). A carve-out asserted without citable evidence fails closed. Pre-existing legacy models merely touched by the diff are N/A; models the diff introduces are in scope.

**Incorrect (every row re-runs when any published property changes):**

```swift
import SwiftUI

final class TrailFilterSettings: ObservableObject {
    @Published var showClosedTrails = false
    @Published var sortByDistance = true
}

struct TrailRow: View {
    let trailName: String
    @ObservedObject var settings: TrailFilterSettings

    var body: some View {
        // Reads only showClosedTrails, yet re-evaluates
        // whenever sortByDistance changes too.
        Text(settings.showClosedTrails ? "\(trailName) (incl. closed)" : trailName)
    }
}
```

**Correct (views re-evaluate only for properties they read):**

```swift
import SwiftUI

@Observable
final class TrailFilterSettings {
    var showClosedTrails = false
    var sortByDistance = true
}

struct TrailRow: View {
    let trailName: String
    let settings: TrailFilterSettings

    var body: some View {
        Text(settings.showClosedTrails ? "\(trailName) (incl. closed)" : trailName)
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Managing state with observable models”.
