---
title: "Use #Expression for Reusable Predicate Components (iOS 18+)"
impact: MEDIUM
impactDescription: eliminates duplicated predicate logic and enables complex aggregate queries
tags: query, expression, predicate, reusable, ios18
---

## Use #Expression for Reusable Predicate Components (iOS 18+)

`#Expression` (iOS 18+) lets you define reusable, composable predicate building blocks that return arbitrary types — not just booleans. This avoids duplicating complex filter logic across multiple predicates and enables aggregate-style queries that `#Predicate` alone cannot express.

**Incorrect (duplicated filter logic across predicates):**

```swift
// Same "high priority" logic repeated in two predicates
let urgentTrips = #Predicate<Trip> { trip in
    trip.priority >= 3 && trip.startDate < .now
}

let urgentUpcoming = #Predicate<Trip> { trip in
    trip.priority >= 3 && trip.startDate < .now && trip.endDate > .now
}
```

**Correct (#Expression extracts reusable logic):**

```swift
let isUrgent = #Expression<Trip, Bool> { trip in
    trip.priority >= 3 && trip.startDate < .now
}

let urgentTrips = #Predicate<Trip> { trip in
    isUrgent.evaluate(trip)
}

let urgentUpcoming = #Predicate<Trip> { trip in
    isUrgent.evaluate(trip) && trip.endDate > .now
}
```

**When NOT to use:**
- Simple, one-off predicates that don't need reuse
- Apps targeting iOS 17 — `#Expression` requires iOS 18+

**Benefits:**
- Single source of truth for complex filter logic
- Expressions compose into predicates without runtime overhead
- Enables aggregate patterns (counting, min/max) within SwiftData queries

Reference: [What's new in SwiftData](https://developer.apple.com/videos/play/wwdc2024/10137/)
