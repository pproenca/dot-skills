---
title: Apply @Model Macro to All Persistent Types
impact: CRITICAL
impactDescription: prevents 100% data loss — unmarked types are never persisted
tags: persist, model-macro, swiftdata, persistence
---

## Apply @Model Macro to All Persistent Types

The `@Model` macro converts a Swift class into a stored model with automatic change tracking, relationship management, and schema generation. Without it, SwiftData has no knowledge of the type and will not persist any instances — data silently disappears on app quit.

**Incorrect (plain class — not persisted):**

```swift
class Friend {
    var name: String
    var birthday: Date

    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}

// This instance lives only in memory — gone when the app closes
let friend = Friend(name: "Alex", birthday: .now)
context.insert(friend)  // ERROR: Cannot convert value of type 'Friend' to expected argument
```

**Correct (@Model class — fully persisted):**

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

// SwiftData tracks this instance and saves it automatically
let friend = Friend(name: "Alex", birthday: .now)
context.insert(friend)
```

**Benefits:**
- Automatic change tracking — no manual save calls needed with environment context
- Schema generated from property declarations
- Relationship inference from type references between `@Model` classes

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
