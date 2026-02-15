---
title: Force View Refresh After Background Context Inserts
impact: HIGH
impactDescription: prevents stale UI that shows outdated data after background imports or sync operations
tags: query, background, refresh, staleness, model-actor, notification
---

## Force View Refresh After Background Context Inserts

`@Query` automatically updates when mutations happen on the same `ModelContext` (typically `mainContext`). However, inserts from a `@ModelActor` background context do not reliably trigger `@Query` updates — this is a known framework limitation. Deletes sync correctly, but inserts and updates from background actors leave the UI stale until the next autosave merge.

**Incorrect (UI stays stale after background import):**

```swift
@ModelActor
actor TripImporter {
    func importTrips(from dtos: [TripDTO]) throws {
        for dto in dtos {
            modelContext.insert(Trip(name: dto.name, startDate: dto.startDate))
        }
        try modelContext.save()
        // Main context @Query will NOT reliably update after this save
    }
}

struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [Trip]

    var body: some View {
        List(trips) { trip in
            Text(trip.name) // Shows stale data until user navigates away and back
        }
    }
}
```

**Correct (observe didSave notification to force refresh):**

```swift
@ModelActor
actor TripImporter {
    func importTrips(from dtos: [TripDTO]) throws {
        for dto in dtos {
            modelContext.insert(Trip(name: dto.name, startDate: dto.startDate))
        }
        try modelContext.save()
    }
}

struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [Trip]
    @State private var refreshToken = UUID()

    var body: some View {
        List(trips) { trip in
            Text(trip.name)
        }
        .id(refreshToken)
        .onReceive(
            NotificationCenter.default.publisher(
                for: ModelContext.didSave,
                object: nil
            )
        ) { _ in
            refreshToken = UUID()
        }
    }
}
```

**When NOT to use:**
- All mutations happen on the same `mainContext` (e.g., simple CRUD from SwiftUI views) — `@Query` updates automatically in this case
- You are using iOS 26+ where Apple may have resolved this framework limitation

**Benefits:**
- Ensures UI reflects background inserts and updates immediately
- Works around the known `@Query`/`@ModelActor` sync gap
- Low overhead — notification fires only on actual saves

Reference: [SwiftData Query not updating after background import — Apple Developer Forums](https://developer.apple.com/forums/thread/761118)
