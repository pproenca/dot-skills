---
title: Annotate SampleData with @MainActor
impact: MEDIUM
impactDescription: prevents concurrency warnings and ensures thread-safe UI access
tags: preview, main-actor, concurrency, thread-safety
---

## Annotate SampleData with @MainActor

`SampleData` accesses `modelContainer.mainContext`, which is bound to the main actor. Without `@MainActor` on the class, the compiler emits concurrency warnings, and access from previews may trigger runtime threading issues under strict concurrency checking.

**Incorrect (missing @MainActor — concurrency warnings, potential crashes):**

```swift
class SampleData {
    static let shared = SampleData()
    let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext // Warning: main actor-isolated property accessed from nonisolated context
    }

    private init() {
        let schema = Schema([Friend.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
    }
}
```

**Correct (class isolated to main actor — safe access guaranteed):**

```swift
@MainActor
class SampleData {
    static let shared = SampleData()
    let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext // Safe — class is on the main actor
    }

    private init() {
        let schema = Schema([Friend.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
    }
}
```

**When NOT to use:**
- Background data processing classes that intentionally work off the main thread should use a dedicated `ModelContext` created from the container, not `mainContext`

**Benefits:**
- Zero concurrency warnings with Swift 6 strict concurrency
- Guaranteed thread safety when previews access `mainContext`
- Clear intent that this class exists for UI-facing preview data

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
