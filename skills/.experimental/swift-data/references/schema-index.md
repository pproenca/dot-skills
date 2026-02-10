---
title: "Use #Index for Hot Predicates and Sorts (iOS 18+)"
impact: LOW-MEDIUM
impactDescription: 10-100x faster queries on large datasets by avoiding full table scans
tags: schema, index, macro, performance, query
---

## Use #Index for Hot Predicates and Sorts (iOS 18+)

If your app runs frequent queries that filter or sort on specific properties (especially on large datasets), add `#Index` for those key paths. `#Index` creates index metadata in the persistent store to make those queries faster and more efficient.

**Incorrect (no index for properties that are frequently filtered/sorted):**

```swift
import SwiftData

@Model
class Trip {
    var name: String
    var startDate: Date
    var endDate: Date

    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}

// If Trip grows large, frequent predicates/sorts on these fields can become slow.
func pageTrips(context: ModelContext, page: Int) throws -> [Trip] {
    var descriptor = FetchDescriptor<Trip>(
        sortBy: [SortDescriptor(\.startDate)]
    )
    descriptor.fetchLimit = 50
    descriptor.fetchOffset = page * 50
    return try context.fetch(descriptor)
}
```

**Correct (index the properties you query and sort on most):**

```swift
import SwiftData

@Model
class Trip {
    // iOS 18+: single and compound indexes are supported.
    #Index<Trip>(
        [\.name],
        [\.startDate],
        [\.endDate],
        [\.name, \.startDate, \.endDate]
    )

    var name: String
    var startDate: Date
    var endDate: Date

    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
```

**When NOT to use:**
- Small datasets where query performance is already acceptable
- Fields that are rarely used in predicates/sorts (indexes add storage and schema/migration surface area)

**Benefits:**
- Faster queries for large datasets
- Better tail latency for common list screens (search, filters, sorted lists)
- Compound indexes can accelerate multi-field predicates and sorts

Reference: [What’s new in SwiftData](https://developer.apple.com/videos/play/wwdc2024/10137/)

