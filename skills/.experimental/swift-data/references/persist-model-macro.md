---
title: Apply @Model Macro to All Persistent Types
impact: CRITICAL
impactDescription: prevents non-persistent types from being mistakenly used with SwiftData APIs
tags: persist, model-macro, swiftdata, persistence
---

## Apply @Model Macro to All Persistent Types

The `@Model` macro converts a Swift class into a SwiftData persistent model with change tracking, relationship management, and schema generation. Non-`@Model` types aren't persistent models, so SwiftData APIs won't accept them for insert/fetch.

**Incorrect (plain class — not a SwiftData persistent model):**

```swift
class Friend {
    var name: String
    var birthday: Date

    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}

// This instance lives only in memory and can't be inserted into SwiftData.
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

// SwiftData can track and persist this instance.
let friend = Friend(name: "Alex", birthday: .now)
context.insert(friend)
```

**Benefits:**
- Automatic change tracking — no manual save calls needed with environment context
- Schema generated from property declarations
- Relationship inference from type references between `@Model` classes

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
