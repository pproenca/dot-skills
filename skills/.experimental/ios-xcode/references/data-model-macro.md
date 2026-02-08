---
title: Use @Model for SwiftData Persistence
impact: CRITICAL
impactDescription: automatic persistence, relationship tracking, integrates with SwiftUI
tags: data, swiftdata, model, persistence, database, ios17
---

## Use @Model for SwiftData Persistence

The `@Model` macro marks a class for SwiftData persistence. SwiftData automatically saves changes, tracks relationships, and integrates with SwiftUI. Use classes (not structs) for SwiftData models.

**Incorrect (struct or missing @Model):**

```swift
// Structs can't be SwiftData models
struct Friend {
    var name: String
    var birthday: Date
}

// Class without @Model won't persist
class Friend {
    var name: String
    var birthday: Date
}
```

**Correct (@Model class):**

```swift
import SwiftData

@Model
class Friend {
    var name: String
    var birthday: Date

    init(name: String, birthday: Date = .now) {
        self.name = name
        self.birthday = birthday
    }
}

@Model
class Movie {
    var title: String
    var releaseDate: Date
    var isFavorite: Bool

    init(title: String, releaseDate: Date = .now, isFavorite: Bool = false) {
        self.title = title
        self.releaseDate = releaseDate
        self.isFavorite = isFavorite
    }
}
```

**@Model requirements:**
- Must be a class (reference type)
- Properties are automatically persisted
- Provide initializer with required properties
- Import SwiftData framework

**SwiftData features:**
- Automatic saving on changes
- Undo/redo support
- CloudKit sync (with configuration)
- Type-safe queries

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
