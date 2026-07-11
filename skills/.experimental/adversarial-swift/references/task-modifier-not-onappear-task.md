---
title: Use the task modifier for view-lifetime async work, not Task inside onAppear
tags: task, lifecycle, cancellation, onappear
---

## Use the task modifier for view-lifetime async work, not Task inside onAppear

The wrong default is `.onAppear { Task { await fetch() } }` — a manually created task "initiates a unit of work that SwiftUI cannot manage," so the framework cannot cancel it when the user navigates away, and a view that appears repeatedly stacks redundant background tasks that keep consuming memory and CPU. The `.task` modifier ties the same work to the view's presence in the hierarchy: if the view is removed before the work finishes, SwiftUI automatically cancels the task.

**Evidence of violation:** a `Task { }` created inside `.onAppear` (or another appearance-driven entry point) whose awaited result populates this view's state. A `Task { }` inside `.onChange` is out of scope here — `task-id-for-async-state-reactions` owns change-driven work. PASS: the same work expressed as `.task { await … }` or `.task(id:)`. Synchronous work inside `.onAppear` — property assignments, run-once guards — is endorsed by the source and never fails this rule. N/A: the spawned work is deliberately view-independent (must outlive the view) AND a comment on the `Task` says so — absent that comment, fail closed. N/A on deployment targets below iOS 15 / macOS 12, where `.task` is unavailable.

**Incorrect (task survives the view and stacks on reappearance):**

```swift
enum BirdDataService { static func fetchBirdNames() async -> [String] { [] } }

struct BirdListView: View {
    @State private var birds: [String] = []

    var body: some View {
        List(birds, id: \.self) { bird in
            Text(bird)
        }
        .onAppear {
            Task {
                birds = await BirdDataService.fetchBirdNames()
            }
        }
    }
}
```

**Correct (SwiftUI cancels the work when the view leaves the hierarchy):**

```swift
enum BirdDataService { static func fetchBirdNames() async -> [String] { [] } }

struct BirdListView: View {
    @State private var birds: [String] = []

    var body: some View {
        List(birds, id: \.self) { bird in
            Text(bird)
        }
        .task {
            birds = await BirdDataService.fetchBirdNames()
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Choosing the right entry point for data initialization”
