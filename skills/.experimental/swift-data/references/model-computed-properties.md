---
title: Use Computed Properties for Derived Data
impact: MEDIUM
impactDescription: keeps logic discoverable and avoids stale stored values
tags: model, computed-properties, derived-data, dry
---

## Use Computed Properties for Derived Data

When a value depends entirely on other properties (e.g., "is birthday today", "full name"), compute it rather than storing it. Stored derived data becomes stale the moment a source property changes, leading to bugs that are hard to trace.

**Incorrect (stored derived value becomes stale):**

```swift
@Model class Friend {
    var name: String
    var birthday: Date
    var isBirthdayToday: Bool  // Stored — stale after midnight

    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
        self.isBirthdayToday = Calendar.current.isDateInToday(birthday)
        // This value is frozen at creation time and never updates
    }
}
```

**Correct (computed property is always fresh):**

```swift
@Model class Friend {
    var name: String
    var birthday: Date

    var isBirthdayToday: Bool {
        Calendar.current.isDateInToday(birthday)
    }

    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}
```

**Benefits:**
- Always returns the correct value — no risk of staleness
- Not persisted to disk — saves storage and avoids migration headaches
- Single source of truth — logic lives in one place

**When NOT to use:**
- Expensive computations that rarely change — consider caching with `@Transient` and manual invalidation
- Values needed in SwiftData predicates — `#Predicate` cannot evaluate computed properties

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
