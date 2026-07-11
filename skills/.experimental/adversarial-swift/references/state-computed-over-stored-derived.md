---
title: Derive related values with computed properties instead of storing copies
tags: state, computed-properties, derived-state, consistency
---

## Derive related values with computed properties instead of storing copies

The wrong default is storing a value that is a pure function of another stored property — keeping both `radius` and `diameter` as stored properties and updating them in tandem. Hand-synchronized copies drift the first time one write path forgets the other, and nothing in the compiler flags the desync. A computed property is dynamically calculated from the source of truth on every read, so the derived value is always correct based on the latest measurements; a setter can write back to the source of truth when two-way access is needed.

**Evidence of violation:** two stored properties in one type where one is deterministically derivable from the other, kept consistent by manual assignments (or not kept consistent at all — a reachable write path updates one without the other). PASS: the derived value is a computed property, optionally with a setter that writes back to the stored source of truth. N/A: the second property is an explicit cache of an expensive computation with invalidation logic the reviewer can cite (the invalidation call sites are the evidence).

**Incorrect (one write path away from inconsistent state):**

```swift
struct HikeStats {
    var distanceKilometers: Double
    var distanceMiles: Double

    mutating func record(kilometers: Double) {
        distanceKilometers = kilometers
        distanceMiles = kilometers * 0.621371
    }

    mutating func reset() {
        distanceKilometers = 0
        // distanceMiles keeps its old value — silent desync
    }
}
```

**Correct (single source of truth, derived value always current):**

```swift
struct HikeStats {
    var distanceKilometers: Double

    var distanceMiles: Double {
        get { distanceKilometers * 0.621371 }
        set { distanceKilometers = newValue / 0.621371 }
    }

    mutating func reset() {
        distanceKilometers = 0
    }
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Leverage computed properties to synchronize related data”.
