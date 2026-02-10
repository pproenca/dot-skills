---
title: Use Arrays for One-to-Many Relationships
impact: MEDIUM-HIGH
impactDescription: ensures SwiftData correctly tracks relationship mutations
tags: rel, one-to-many, array, relationship
---

## Use Arrays for One-to-Many Relationships

For one-to-many relationships (e.g., a movie favorited by many friends), use an array property with a default empty array. SwiftData manages the array contents automatically when the inverse relationship changes. Using Set or custom collection types breaks SwiftData's change tracking because the framework only instruments Array-backed relationships.

**Incorrect (Set or custom collection — SwiftData cannot track changes):**

```swift
import SwiftData

@Model class Movie {
    var title: String
    // SwiftData does not track Set mutations — changes silently lost
    var favoritedBy: Set<Friend> = []

    init(title: String) {
        self.title = title
    }
}
```

**Correct (Array with empty default — auto-maintained by SwiftData):**

```swift
import SwiftData

@Model class Movie {
    var title: String
    var favoritedBy: [Friend] = []

    init(title: String) {
        self.title = title
    }
}
```

**Benefits:**
- SwiftData automatically appends/removes elements when the inverse side changes
- Array contents are persisted and restored across launches
- Compatible with SwiftUI's `ForEach` for direct iteration

Reference: [Develop in Swift — Work with Relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)
