---
title: Restart async work with the task id modifier, not Tasks spawned in onChange
tags: task, onchange, task-id, cancellation
---

## Restart async work with the task id modifier, not Tasks spawned in onChange

The wrong default is reacting to a value change by spawning a manual `Task` inside `.onChange` — every change starts another unmanaged task, so rapid changes race each other and stale results overwrite fresh ones. The book states that when a state change requires an asynchronous operation, `task(id:priority:_:)` is the preferred choice: "If the identifier updates while a previous task is still running, the framework automatically cancels the old task and starts a new one in its place," and the work is stopped when the view is removed.

**Evidence of violation:** an `.onChange(of:)` closure that creates a `Task { }` performing async work whose result feeds this view's state. PASS: the same reaction expressed as `.task(id:) { await … }`. N/A: the `.onChange` reaction is synchronous (label updates, haptics — the book's sanctioned use of `onChange`), or there is no change-driven async work in the target.

**Incorrect (concurrent fetches race; the older response can land last):**

```swift
enum DepartmentOfConservation { static func fetchHuts(for regionID: String) async -> [String] { [] } }

struct HutAvailabilityView: View {
    let regionID: String

    @State private var availableHuts: [String] = []

    var body: some View {
        List(availableHuts, id: \.self) { hut in
            Text(hut)
        }
        .onChange(of: regionID) { _, newValue in
            Task {
                availableHuts = await DepartmentOfConservation.fetchHuts(for: newValue)
            }
        }
    }
}
```

**Correct (previous fetch is cancelled when the identifier changes):**

```swift
enum DepartmentOfConservation { static func fetchHuts(for regionID: String) async -> [String] { [] } }

struct HutAvailabilityView: View {
    let regionID: String

    @State private var availableHuts: [String] = []

    var body: some View {
        List(availableHuts, id: \.self) { hut in
            Text(hut)
        }
        .task(id: regionID) {
            availableHuts = await DepartmentOfConservation.fetchHuts(for: regionID)
        }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Running tasks in response to state changes”
