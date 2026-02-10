---
title: "Use #Unique for Compound Uniqueness (iOS 18+)"
impact: LOW-MEDIUM
impactDescription: avoids duplicates by enforcing compound identity and enabling upsert on collision
tags: schema, unique, macro, compound, upsert
---

## Use #Unique for Compound Uniqueness (iOS 18+)

Use the `#Unique` schema macro when a model's identity is defined by a *combination* of properties (compound uniqueness). When two model instances share the same unique values, SwiftData performs an upsert on collision with the existing model.

**Incorrect (single-field uniqueness causes unintended collisions):**

```swift
import SwiftData

@Model
class Trip {
    // Too strict: trips collide on name even when dates differ.
    @Attribute(.unique) var name: String
    var startDate: Date
    var endDate: Date

    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
```

**Correct (compound uniqueness matches the model's identity):**

```swift
import SwiftData

@Model
class Trip {
    // iOS 18+: enforce compound identity.
    #Unique<Trip>([\.name, \.startDate, \.endDate])

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
- Single-property natural keys (e.g., email, external ID) can use `@Attribute(.unique)`
- Apps that don't target iOS 18+ should model identity explicitly in code (fetch-by-key) and/or via a single unique attribute

**Benefits:**
- Avoids duplicates without forcing an overly strict single-field identity
- Encodes model identity at the schema level (so all code paths benefit)
- Upsert-on-collision behavior simplifies imports when identity is compound

Reference: [What’s new in SwiftData](https://developer.apple.com/videos/play/wwdc2024/10137/)

