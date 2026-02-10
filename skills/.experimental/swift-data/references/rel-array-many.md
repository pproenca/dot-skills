---
title: Use Arrays for One-to-Many Relationships
impact: MEDIUM-HIGH
impactDescription: aligns relationship modeling with Apple’s SwiftData examples and common SwiftUI iteration patterns
tags: rel, one-to-many, array, relationship
---

## Use Arrays for One-to-Many Relationships

For one-to-many relationships (e.g., a movie favorited by many friends), use an array property with a default empty array. Apple’s SwiftData examples model to-many relationships as arrays, which integrates cleanly with SwiftUI’s `ForEach` and keeps relationship ordering explicit.

**Incorrect (Set-based to-many relationship — non-canonical, harder to iterate and reason about):**

```swift
import SwiftData

@Model class Movie {
    var title: String
    var favoritedBy: Set<Friend> = []

    init(title: String) {
        self.title = title
    }
}
```

**Correct (Array with empty default):**

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
