---
title: Use @ModelActor for Background SwiftData Work
impact: CRITICAL
impactDescription: prevents data corruption and crashes from cross-actor model access
tags: persist, model-actor, concurrency, background, sendable
---

## Use @ModelActor for Background SwiftData Work

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

`PersistentModel` and `ModelContext` are not `Sendable` — passing them across actor boundaries causes data races and crashes. For background work (imports, batch updates, sync), use the `@ModelActor` macro to create an actor with its own `ModelContext` isolated from the main actor.

**Incorrect (sharing model context across actors — data race):**

```swift
import SwiftData

struct FriendImporter {
    let context: ModelContext // Not Sendable — unsafe to use off main actor

    func importFriends(from data: [FriendDTO]) async {
        await Task.detached {
            for dto in data {
                // BUG: accessing context from a non-main-actor task
                // causes data races and intermittent crashes
                context.insert(Friend(name: dto.name, birthday: dto.birthday))
            }
            try? context.save()
        }.value
    }
}
```

**Correct (@ModelActor creates an actor-isolated context):**

```swift
import SwiftData

@ModelActor
actor FriendImporter {
    // @ModelActor provides: modelContainer, modelExecutor, and a private modelContext

    func importFriends(from data: [FriendDTO]) throws {
        for dto in data {
            let friend = Friend(name: dto.name, birthday: dto.birthday)
            modelContext.insert(friend)
        }
        try modelContext.save()
    }
}

// Usage from a view or main-actor code:
let importer = FriendImporter(modelContainer: container)
try await importer.importFriends(from: dtos)
```

**When NOT to use:**
- Simple CRUD from SwiftUI views — use `@Environment(\.modelContext)` instead
- One-off fetches that are fast enough on the main actor

**UI refresh caveat:**
Inserts from a `@ModelActor` do not reliably trigger `@Query` updates in SwiftUI views. If your UI depends on seeing background-inserted data immediately, you must observe `ModelContext.didSave` notifications and force a view refresh. See [`query-background-refresh`](query-background-refresh.md) for the full workaround pattern.

**Benefits:**
- Actor isolation guarantees serial access to the context — no data races
- `DefaultSerialModelExecutor` ensures operations run one-by-one
- `ModelContainer` is `Sendable` and safe to pass to the actor initializer

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)
