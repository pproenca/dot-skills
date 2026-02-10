---
title: Provide Custom Initializers for Model Classes
impact: HIGH
impactDescription: prevents compile errors — Swift doesn't auto-generate memberwise init for classes
tags: model, initializer, class, swiftdata
---

## Provide Custom Initializers for Model Classes

Unlike structs, Swift classes do not get automatic memberwise initializers. Every `@Model` class must declare its own `init` or the project will not compile. This is one of the most common mistakes when converting struct-based prototypes to SwiftData models.

**Incorrect (missing initializer — won't compile):**

```swift
import SwiftData

@Model class Friend {
    var name: String
    var birthday: Date
    // ERROR: Class 'Friend' has no initializers
}
```

**Correct (explicit memberwise initializer):**

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

**Alternative (defaults reduce init parameters):**

```swift
@Model class Friend {
    var name: String
    var birthday: Date = .now
    var notes: String = ""

    init(name: String, birthday: Date = .now, notes: String = "") {
        self.name = name
        self.birthday = birthday
        self.notes = notes
    }
}

// Can now create with just a name
let friend = Friend(name: "Alex")
```

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
