---
title: Pass leaf views the values they read not whole models
tags: update, data-dependencies, minimal-interface, reusability
---

## Pass leaf views the values they read not whole models

The wrong default is passing an entire model struct into a small leaf view that uses a single field of it. The whole struct becomes part of the subview's view value, so the subview is re-evaluated whenever any property of the model changes — even fields it never reads — repeating any internal lookups for updates that have no impact on its UI. It also ties the component to one model type, blocking reuse. Passing only the primitive value, ID, or focused `Binding` the view actually uses gives SwiftUI a narrow dependency it can compare cheaply and skip.

**Evidence of violation:** a subview whose stored property is a full model struct while its `body` (plus its computed properties) reads exactly one property or ID of that model. PASS: the subview accepts the specific value, ID, or `Binding` it uses. N/A: the subview reads two or more distinct properties of the model (the gate fails only the unambiguous single-read case), or the model is an `@Observable` class — reference types get property-level tracking and a cheap pointer comparison, so the broad parameter is not the same hazard.

**Incorrect (any change to any Trail field re-evaluates the section):**

```swift
import SwiftUI

struct Trail: Identifiable {
    let id: UUID
    var name: String
    var lengthKm: Double
    var regionID: UUID
}

struct TrailRegionSection: View {
    let trail: Trail

    var body: some View {
        Text("Region: \(trail.regionID.uuidString)")
    }
}
```

**Correct (depends only on the one value it renders):**

```swift
import SwiftUI

struct Trail: Identifiable {
    let id: UUID
    var name: String
    var lengthKm: Double
    var regionID: UUID
}

struct TrailRegionSection: View {
    let regionID: UUID

    var body: some View {
        Text("Region: \(regionID.uuidString)")
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Minimizing data dependencies”.
