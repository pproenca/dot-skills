---
title: Tune FetchDescriptor with fetchLimit/fetchOffset and includePendingChanges
impact: MEDIUM
impactDescription: reduces memory and I/O by paging results and controlling whether unsaved edits are included
tags: query, fetch-descriptor, tuning, pagination, performance
---

## Tune FetchDescriptor with fetchLimit/fetchOffset and includePendingChanges

When you need paging, background reporting, or predictable performance outside SwiftUI views, tune `FetchDescriptor` instead of fetching everything and slicing in memory. Use `fetchLimit` and `fetchOffset` for paging, and choose whether to include unsaved in-context edits with `includePendingChanges`.

**Incorrect (fetch everything, then page in memory):**

```swift
import SwiftData

func pageTrips(context: ModelContext, page: Int) throws -> [Trip] {
    let pageSize = 50

    // Loads the full result set into memory.
    let allTrips = try context.fetch(FetchDescriptor<Trip>())

    let start = page * pageSize
    return Array(allTrips.dropFirst(start).prefix(pageSize))
}
```

**Correct (page at the fetch layer with a stable sort):**

```swift
import SwiftData

func pageTrips(context: ModelContext, page: Int) throws -> [Trip] {
    let pageSize = 50

    var descriptor = FetchDescriptor<Trip>(
        sortBy: [SortDescriptor(\.startDate)]
    )
    descriptor.fetchLimit = pageSize
    descriptor.fetchOffset = page * pageSize

    // For background work and stable paging, avoid mixing in unsaved edits.
    descriptor.includePendingChanges = false

    return try context.fetch(descriptor)
}
```

**When NOT to use:**
- Inside SwiftUI views that should live-update from persistence: prefer `@Query`
- Very small datasets where simplicity matters more than tuning

**Benefits:**
- Bounded memory usage for large result sets
- More predictable paging behavior (pair offset/limit with a stable sort)
- Control over whether unsaved edits in the current context affect fetch results

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/) and [FetchDescriptor.fetchOffset](https://developer.apple.com/documentation/swiftdata/fetchdescriptor/fetchoffset)

