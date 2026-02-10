---
title: Use ModelContext.enumerate for Large Traversals
impact: MEDIUM
impactDescription: enables efficient batch traversal with configurable batching and mutation guards
tags: persist, enumerate, batch, model-context, performance
---

## Use ModelContext.enumerate for Large Traversals

For large traversals (imports, maintenance jobs, background processing), prefer `ModelContext.enumerate` over `fetch + for-in`. `enumerate` batches objects automatically (default batch size is 5,000) and includes a mutation guard to prevent performance issues from a "dirty" context during enumeration.

**Incorrect (fetch everything, then traverse a large array in memory):**

```swift
import SwiftData

func normalizeTripNames(context: ModelContext) throws {
    // Pulls the entire dataset into memory at once.
    let trips = try context.fetch(FetchDescriptor<Trip>())

    for trip in trips {
        trip.name = trip.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    try context.save()
}
```

**Correct (enumerate in batches; opt into mutations when you intend to modify models):**

```swift
import SwiftData

func normalizeTripNames(context: ModelContext) throws {
    let descriptor = FetchDescriptor<Trip>()

    try context.enumerate(
        descriptor,
        batchSize: 1000,
        allowEscapingMutations: true
    ) { trip in
        trip.name = trip.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    try context.save()
}
```

**Pitfalls:**
- `enumerate` throws if it detects the `ModelContext` is dirty and `allowEscapingMutations` is not set
- If you mutate a lot of objects, consider saving periodically (and structuring work so the context can release objects) to avoid unbounded memory growth

**Benefits:**
- Efficient traversal for large datasets via batching
- Mutation guard prevents a common class of large-traversal performance problems
- Configurable batch size to trade memory for I/O based on your object graph

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)

