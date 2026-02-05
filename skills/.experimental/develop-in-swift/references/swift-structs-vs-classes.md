---
title: Prefer Structs Over Classes
impact: CRITICAL
impactDescription: value semantics prevent shared mutable state bugs, structs are faster
tags: swift, structs, classes, value-types, reference-types
---

## Prefer Structs Over Classes

Structs are value types - they're copied when passed around. Classes are reference types - they share identity. Prefer structs for data models unless you need class-specific features like inheritance or reference identity.

**Incorrect (class for simple data model):**

```swift
class Friend {
    var name: String

    init(name: String) {
        self.name = name
    }
}

var friendClass = Friend(name: "Elena")
var otherFriendClass = friendClass
friendClass.name = "Graham"
// otherFriendClass.name is also "Graham" - shared reference!
```

**Correct (struct for value semantics):**

```swift
struct Friend {
    var name: String
}

var friendStruct = Friend(name: "Elena")
var otherFriendStruct = friendStruct
friendStruct.name = "Graham"
// friendStruct.name = "Graham"
// otherFriendStruct.name = "Elena" - independent copy!
```

**When to use classes:**
- SwiftData models (require `@Model` which needs classes)
- Shared mutable state that must be observed across views
- Inheritance hierarchies
- Identity comparison (`===`) is needed

**When to use structs:**
- Simple data containers
- SwiftUI views (all views are structs)
- Immutable or independently copyable data
- Thread-safe data transfer

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)
