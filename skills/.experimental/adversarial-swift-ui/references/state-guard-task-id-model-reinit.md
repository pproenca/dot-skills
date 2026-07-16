---
title: Guard model re-creation in task id closures with an identity check
tags: state, task-id, model-lifecycle, navigationstack
---

## Guard model re-creation in task id closures with an identity check

The wrong default is assuming `.task(id:)` runs only on insertion and on id changes, and re-creating a model unconditionally inside it. SwiftUI can re-run the modifier during the view's lifetime even when the id has not changed — for example, within a `NavigationStack` when an intermediate destination reappears after a view pushed on top of it is dismissed. An unguarded `viewModel = Model(id:)` assignment then replaces a live model, silently discarding everything the user accumulated in it (draft text, selections, loaded data). A one-line identity comparison before the assignment makes the re-run harmless.

**Evidence of violation:** a `.task(id:)` closure that assigns a freshly initialized model or view-model object to state without first comparing the existing value's identity to the id (the shape `if viewModel?.id != animalID { viewModel = ...(id: animalID) }` is absent). PASS: the assignment is guarded by an identity check, or the closure only fetches data into value-typed state without re-creating a state-holding model object. N/A: no model re-creation inside a `.task(id:)` in the target.

**Incorrect (a NavigationStack re-run silently replaces the live model):**

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
            // ⚠️ Re-runs with an unchanged id replace the live model
            viewModel = AnimalDetailViewModel(id: animalID)
        }
    }
}
```

**Correct (re-runs with an unchanged id keep the live model):**

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
