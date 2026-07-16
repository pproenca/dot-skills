---
title: Do not seed State from init parameters with State initialValue
tags: state, state-initialvalue, stale-data, task-id
---

## Do not seed State from init parameters with State initialValue

The wrong default is assigning `_property = State(initialValue: ...)` in a view's `init` from a value the parent passes in. SwiftUI only uses the `initialValue` of a `@State` property the very first time the view is inserted into the hierarchy; when the parent later updates the parameter, the view's `init` runs again but the state assignment is ignored, and SwiftUI reconnects the struct to the original stored instance created with the old value. The view's state silently goes out of sync with what the parent passed — a stale-data bug with no crash or warning.

**Evidence of violation:** `State(initialValue:)` or `State(wrappedValue:)` assigned inside a view `init` where the value derives from an `init` parameter. PASS: the model or value is created in `.task(id:)` keyed on the parameter (with an identity check guarding re-runs), or the `@State` property defaults to `nil` or a constant. N/A: `State(initialValue:)` fed only by compile-time constants — first-insertion semantics are then harmless.

**Incorrect (parent updates to habitatId are silently ignored):**

```swift
import SwiftUI

@Observable class HabitatViewModel {
    let id: UUID
    var name = ""
    var description = ""

    init(id: UUID) {
        self.id = id
    }
}

struct HabitatInfo: View {
    @State private var viewModel: HabitatViewModel

    init(habitatId: UUID) {
        // ⚠️ State assignment is skipped after its first initialization
        _viewModel = State(initialValue: HabitatViewModel(id: habitatId))
    }

    var body: some View {
        VStack {
            Text(viewModel.name)
            Text(viewModel.description)
        }
    }
}
```

**Correct (model tracks the parameter through the task identity):**

```swift
import SwiftUI

@Observable class AnimalDetailViewModel {
    let id: UUID
    var description = ""

    init(id: UUID) {
        self.id = id
    }
}

struct AnimalDetail: View {
    let animalID: UUID

    @State private var viewModel: AnimalDetailViewModel?

    var body: some View {
        VStack {
            Text(viewModel?.description ?? "")
            // ... subviews ...
        }
        .task(id: animalID) {
            if viewModel?.id != animalID {
                viewModel = AnimalDetailViewModel(id: animalID)
            }
        }
    }
}
```
