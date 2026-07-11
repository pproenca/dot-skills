---
title: Store view-created observable models in State not plain properties
tags: state, observation, model-ownership, view-lifecycle
---

## Store view-created observable models in State not plain properties

The wrong default is holding a model the view creates in an ordinary stored property (`private var model = TripPlanner()`). View structs are ephemeral — SwiftUI recreates them constantly to compare values — so a model stored as a standard property is re-initialized, and its state reset, every time the view struct is initialized. `@State` tells SwiftUI to manage the model's storage on the view's behalf, keeping the instance alive and persistent for as long as the view remains in the hierarchy.

**Evidence of violation:** a view struct that initializes a reference-type model as the default value of a non-`@State` stored property (`private var model = TripPlanner()` or `let model = TripPlanner()`). PASS: `@State private var model = TripPlanner()`, or the instance is injected by the parent or environment rather than created here. N/A: the property is injected with no default value (`let model: TripPlanner`) — ownership then belongs to the parent, which is where this rule applies instead.

**Incorrect (model resets every time the parent re-evaluates):**

```swift
import SwiftUI

@Observable
final class TripPlanner {
    var selectedTrailIDs: Set<UUID> = []
}

struct TripPlanningView: View {
    private let planner = TripPlanner()

    var body: some View {
        Text("\(planner.selectedTrailIDs.count) trails selected")
    }
}
```

**Correct (SwiftUI keeps the same instance alive across struct recreations):**

```swift
import SwiftUI

@Observable
final class TripPlanner {
    var selectedTrailIDs: Set<UUID> = []
}

struct TripPlanningView: View {
    @State private var planner = TripPlanner()

    var body: some View {
        Text("\(planner.selectedTrailIDs.count) trails selected")
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Managing state with observable models”.
