---
title: Mark Non-Persistent Properties with @Transient
impact: MEDIUM
impactDescription: prevents unnecessary storage and migration complexity
tags: model, transient, persistence, storage
---

## Mark Non-Persistent Properties with @Transient

Properties that should not be persisted (runtime-only state, cached computations, ephemeral data) must be marked `@Transient`. Otherwise SwiftData stores them to disk, wasting space and complicating schema migrations when you later remove them.

**Incorrect (ephemeral data persisted to disk):**

```swift
@Model class Trip {
    var destination: String
    var startDate: Date
    var currentWeather: String = "unknown"  // Persisted — stale on next launch
    var isSelected: Bool = false            // UI state saved to disk unnecessarily

    init(destination: String, startDate: Date) {
        self.destination = destination
        self.startDate = startDate
    }
}
```

**Correct (transient properties excluded from storage):**

```swift
@Model class Trip {
    var destination: String
    var startDate: Date

    @Transient var currentWeather: String = "unknown"  // Fetched fresh each launch
    @Transient var isSelected: Bool = false             // UI-only, never persisted

    init(destination: String, startDate: Date) {
        self.destination = destination
        self.startDate = startDate
    }
}
```

**When NOT to use:**
- Data the user expects to survive app restarts must remain persistent
- Properties used in `#Predicate` queries — transient properties cannot be queried

**Benefits:**
- Smaller database footprint
- No migration needed if transient properties change
- Clear separation between persistent state and runtime state

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
