---
title: Use @Attribute(.unique) for Natural Keys
impact: LOW-MEDIUM
impactDescription: prevents duplicate records from repeated imports or syncs
tags: schema, unique, attribute, constraint, deduplication
---

## Use @Attribute(.unique) for Natural Keys

When a property should be unique across all instances (e.g., email, external ID), mark it with `@Attribute(.unique)`. This adds a uniqueness constraint at the persistence layer. SwiftData can also update an existing record when you attempt to insert another model with the same unique value (an "upsert"), but for imports and syncs you should still consider an explicit fetch-update-insert flow when you need deterministic merge behavior.

**Incorrect (no uniqueness constraint — duplicates from repeated imports):**

```swift
@Model class User {
    var email: String
    var name: String

    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}

// Importing the same server response twice:
context.insert(User(email: "elena@example.com", name: "Elena"))
context.insert(User(email: "elena@example.com", name: "Elena"))
// Result: two User records with the same email
```

**Correct (unique attribute + deterministic upsert):**

```swift
import SwiftData

@Model class User {
    @Attribute(.unique) var email: String
    var name: String

    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}

// Deterministic upsert: fetch existing by natural key, else insert.
func upsertUser(email: String, name: String, context: ModelContext) throws {
    var descriptor = FetchDescriptor<User>(
        predicate: #Predicate { $0.email == email }
    )
    descriptor.fetchLimit = 1

    if let existing = try context.fetch(descriptor).first {
        existing.name = name
    } else {
        context.insert(User(email: email, name: name))
    }

    try context.save()
}
```

**When NOT to use:**
- Properties that legitimately repeat across instances (e.g., city names, categories)
- Composite uniqueness — `@Attribute(.unique)` applies to single properties; for compound identity, use the `#Unique` schema macro (iOS 18+)

**Benefits:**
- Enforces uniqueness at the persistence layer
- Makes imports and syncs safer when paired with an explicit upsert strategy
- Storage-level enforcement regardless of code paths

Reference: [Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/)
