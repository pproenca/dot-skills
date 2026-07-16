---
title: Restart async work with the task id modifier, not Tasks spawned in onChange
tags: task, onchange, task-id, cancellation
---

## Restart async work with the task id modifier, not Tasks spawned in onChange

The wrong default is reacting to a value change by spawning a manual `Task` inside `.onChange` — every change starts another unmanaged task, so rapid changes race each other and a stale response can land after a fresh one and overwrite it. The source names `task(id:priority:_:)` as the preferred choice for change-driven async work: when the identifier updates while a previous task is still running, the framework cancels the old task and starts a new one in its place, and any in-flight work is stopped when the view leaves the hierarchy.

**Evidence of violation:** an `.onChange(of:)` closure that creates a `Task { }` performing async work whose result feeds this view's state. PASS: the same reaction expressed as `.task(id:) { await … }`. Synchronous side effects inside `.onChange` — label updates, haptics — are the source's sanctioned use of the modifier and never fail this rule. N/A: no change-driven async work in the target. N/A on deployment targets below iOS 15 / macOS 12, where `.task(id:)` is unavailable.

**Incorrect (concurrent fetches race; the older response can land last):**

```swift
import SwiftUI

enum DepartmentOfConservation {
    static func fetchHuts(for regionID: String) async -> [String] { [] }
}

struct HutAvailabilityView: View {
    let regionID: String

    @State private var availableHuts: [String] = []

    var body: some View {
        List(availableHuts, id: \.self) { hut in
            Text(hut)
        }
        .onChange(of: regionID) { _, newValue in
            // ⚠️ Manual tasks race and are never cancelled
            Task {
                availableHuts = await DepartmentOfConservation.fetchHuts(
                    for: newValue
                )
            }
        }
    }
}
```

**Correct (previous fetch is cancelled when the identifier changes):**

```swift
import SwiftUI

enum DepartmentOfConservation {
    static func fetchHuts(for regionID: String) async -> [String] { [] }
}

struct HutAvailabilityView: View {
    let regionID: String

    @State private var availableHuts: [String] = []

    var body: some View {
        List(availableHuts, id: \.self) { hut in
            Text(hut)
        }
        .task(id: regionID) {
            availableHuts = await DepartmentOfConservation.fetchHuts(
                for: regionID
            )
        }
    }
}
```
