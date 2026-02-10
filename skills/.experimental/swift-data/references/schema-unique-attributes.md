---
title: Use @Attribute(.unique) for Natural Keys
impact: LOW-MEDIUM
impactDescription: prevents duplicate records from repeated imports or syncs
tags: schema, unique, attribute, constraint, deduplication
---

## Use @Attribute(.unique) for Natural Keys

When a property should be unique across all instances (e.g., email, external ID), mark it with `@Attribute(.unique)`. SwiftData enforces this at the storage level — inserting a model with a duplicate unique value performs an upsert, updating the existing record instead of creating a duplicate.

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

**Correct (unique attribute prevents duplicates):**

```swift
@Model class User {
    @Attribute(.unique) var email: String
    var name: String

    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}

// Second insert with same email updates the existing record:
context.insert(User(email: "elena@example.com", name: "Elena"))
context.insert(User(email: "elena@example.com", name: "Elena Rodriguez"))
// Result: one User record with name "Elena Rodriguez"
```

**When NOT to use:**
- Properties that legitimately repeat across instances (e.g., city names, categories)
- Composite uniqueness — `@Attribute(.unique)` applies to single properties; composite keys require manual validation

**Benefits:**
- Idempotent imports — safe to re-import data without deduplication logic
- Automatic upsert behavior keeps data current
- Storage-level enforcement regardless of code paths

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
