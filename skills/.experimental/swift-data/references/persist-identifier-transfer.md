---
title: Pass PersistentIdentifier Instead of Model Objects Across Actors
impact: HIGH
impactDescription: prevents crashes from non-Sendable model objects crossing actor boundaries
tags: persist, persistent-identifier, concurrency, sendable, actor
---

## Pass PersistentIdentifier Instead of Model Objects Across Actors

`PersistentModel` objects are not `Sendable` — they are tied to the `ModelContext` that created them. To reference a model from another actor (e.g., a background importer returning results to the main actor), pass its `PersistentIdentifier` and re-fetch the object in the target context.

**Incorrect (passing model object across actors — crash or silent corruption):**

```swift
@ModelActor
actor TripProcessor {
    func processTrip(_ trip: Trip) throws {
        // BUG: trip belongs to the main actor's context
        // Accessing it here causes a data race
        trip.name = trip.name.trimmingCharacters(in: .whitespaces)
        try modelContext.save()
    }
}
```

**Correct (pass identifier, re-fetch in local context):**

```swift
@ModelActor
actor TripProcessor {
    func processTrip(id: PersistentIdentifier) throws {
        guard let trip = modelContext.model(for: id) as? Trip else { return }
        trip.name = trip.name.trimmingCharacters(in: .whitespaces)
        try modelContext.save()
    }
}

// Caller passes the identifier, not the object
let processor = TripProcessor(modelContainer: container)
try await processor.processTrip(id: trip.persistentModelID)
```

**When NOT to use:**
- When both sender and receiver share the same `ModelContext` (same actor)
- Passing simple value-type data extracted from a model (e.g., `trip.name`) is already safe

**Benefits:**
- `PersistentIdentifier` conforms to `Sendable` — safe to pass anywhere
- Each actor fetches from its own context, respecting actor isolation
- Works with both `@ModelActor` and manually created background contexts

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)
