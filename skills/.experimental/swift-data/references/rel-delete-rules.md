---
title: Configure Cascade Delete Rules for Owned Relationships
impact: MEDIUM
impactDescription: prevents orphaned records when parent is deleted
tags: rel, cascade, delete-rule, relationship, data-integrity
---

## Configure Cascade Delete Rules for Owned Relationships

When a parent model owns its children (e.g., a trip owns its accommodations), use `@Relationship(deleteRule: .cascade)` so deleting the parent also deletes all children. Without an explicit cascade rule, SwiftData uses the default nullify behavior, which sets the child's reference to nil but leaves the child record in the store — orphaned and inaccessible forever.

**Incorrect (default delete rule — deleting trip orphans accommodations):**

```swift
import SwiftData

@Model class Trip {
    var name: String
    var accommodations: [Accommodation] = []

    init(name: String) {
        self.name = name
    }
}

@Model class Accommodation {
    var address: String
    var trip: Trip?

    init(address: String, trip: Trip? = nil) {
        self.address = address
        self.trip = trip
    }
}

// Deleting a trip leaves its accommodations in the database with trip == nil
```

**Correct (cascade delete rule — children removed with parent):**

```swift
import SwiftData

@Model class Trip {
    var name: String
    @Relationship(deleteRule: .cascade) var accommodations: [Accommodation] = []

    init(name: String) {
        self.name = name
    }
}

@Model class Accommodation {
    var address: String
    var trip: Trip?

    init(address: String, trip: Trip? = nil) {
        self.address = address
        self.trip = trip
    }
}

// Deleting a trip now also deletes all its accommodations
```

**When NOT to use:**
- Shared children referenced by multiple parents (e.g., tags used by many items) — cascade would delete the tag when any single parent is removed
- Use the default nullify rule when children should survive parent deletion

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
