---
title: Use FetchDescriptor Outside SwiftUI Views
impact: MEDIUM
impactDescription: enables data access in background tasks, services, and tests
tags: query, fetch-descriptor, non-swiftui, background
---

## Use FetchDescriptor Outside SwiftUI Views

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

`@Query` only works inside SwiftUI views. For background tasks, services, or unit tests, use `FetchDescriptor` with `context.fetch()`. It supports the same predicates and sort descriptors, giving you full query power outside the view layer.

**Incorrect (using @Query in a non-view class):**

```swift
class TripService {
    // ERROR: @Query can only be used in a SwiftUI View
    @Query private var trips: [Trip]

    func upcomingTrips() -> [Trip] {
        return trips.filter { $0.startDate > Date.now }
    }
}
```

**Correct (FetchDescriptor with context.fetch):**

```swift
class TripService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func upcomingTrips() throws -> [Trip] {
        var descriptor = FetchDescriptor<Trip>(
            predicate: #Predicate { $0.startDate > Date.now },
            sortBy: [SortDescriptor(\.startDate)]
        )
        descriptor.fetchLimit = 50
        return try context.fetch(descriptor)
    }
}
```

**When NOT to use:**
- Inside SwiftUI views — prefer `@Query` for automatic view updates
- If you need live-updating results in a view, `FetchDescriptor` will not trigger re-renders

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
