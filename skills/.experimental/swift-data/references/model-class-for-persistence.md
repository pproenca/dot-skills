---
title: Use Classes for SwiftData Persistent Models
impact: CRITICAL
impactDescription: prevents compile-time error — @Model requires class, not struct
tags: model, class, struct, swiftdata, persistence
---

## Use Classes for SwiftData Persistent Models

SwiftData requires classes (not structs) because persistent instances need built-in identity for sharing across the app. When multiple views reference the same record, they must all point to the same object. Struct copies would break SwiftData's change tracking and cause silent data loss.

**Incorrect (struct with @Model — compiler error):**

```swift
import SwiftData

// ERROR: @Model requires a class declaration
@Model struct Friend {
    var name: String
    var birthday: Date
}
```

**Correct (class with @Model):**

```swift
import SwiftData

@Model class Friend {
    var name: String
    var birthday: Date

    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}
```

**When NOT to use:**
- Plain data transfer objects that never touch persistence can stay as structs
- Embedded value types within a model (e.g., `struct Address: Codable`) are fine as stored properties

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
