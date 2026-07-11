---
title: Do not seed State from init parameters with State initialValue
tags: state, state-initialvalue, stale-data, task-id
---

## Do not seed State from init parameters with State initialValue

The wrong default is assigning `_property = State(initialValue: ...)` in a view's `init` from a value the parent passes in. SwiftUI only uses the `initialValue` of a `@State` property the very first time the view is inserted into the hierarchy; when the parent later updates the parameter, the view's `init` runs again but the state assignment is ignored, and SwiftUI reconnects the struct to the original stored instance. The view's state silently goes out of sync with what the parent passed — a stale-data bug with no crash or warning.

**Evidence of violation:** `State(initialValue:)` or `State(wrappedValue:)` assigned inside a view `init` where the value derives from an `init` parameter. PASS: the model or value is created in `.task(id:)` keyed on the parameter (with an identity check guarding re-runs), or the `@State` property defaults to `nil` or a constant. N/A: `State(initialValue:)` fed only by compile-time constants — first-insertion semantics are then harmless.

**Incorrect (parent updates to trailID are silently ignored):**

```swift
import SwiftUI

@Observable
final class TrailDetailModel {
    let trailID: UUID
    init(trailID: UUID) { self.trailID = trailID }
}

struct TrailDetailView: View {
    @State private var model: TrailDetailModel

    init(trailID: UUID) {
        _model = State(initialValue: TrailDetailModel(trailID: trailID))
    }

    var body: some View {
        Text(model.trailID.uuidString)
    }
}
```

**Correct (model tracks the parameter through the task identity):**

```swift
import SwiftUI

@Observable
final class TrailDetailModel {
    let trailID: UUID
    init(trailID: UUID) { self.trailID = trailID }
}

struct TrailDetailView: View {
    let trailID: UUID
    @State private var model: TrailDetailModel?

    var body: some View {
        Text(model?.trailID.uuidString ?? "Loading")
            .task(id: trailID) {
                if model?.trailID != trailID {
                    model = TrailDetailModel(trailID: trailID)
                }
            }
    }
}
```

Reference: expert SwiftUI reference (2026), “Managing state with observable models”.
