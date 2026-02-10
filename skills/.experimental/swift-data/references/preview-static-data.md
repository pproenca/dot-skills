---
title: Define Static Sample Data on Model Types
impact: MEDIUM
impactDescription: reduces preview setup duplication by 80%+
tags: preview, static-data, model, convention
---

## Define Static Sample Data on Model Types

Add a `static let sampleData` array to each `@Model` class. This keeps sample data next to the model definition, making it easy to find and update when properties change.

**Incorrect (sample data scattered across preview files — hard to keep in sync):**

```swift
// PreviewHelpers.swift — far from model definition
let sampleFriends = [
    Friend(name: "Elena", birthday: Date(timeIntervalSince1970: 0)),
    Friend(name: "Graham", birthday: Date(timeIntervalSince1970: 86400))
]

// AnotherPreview.swift — slightly different data, now out of sync
let previewFriends = [
    Friend(name: "Elena", birthday: .now),
    Friend(name: "Graham", birthday: .now),
    Friend(name: "Jaya", birthday: .now)
]
```

**Correct (sample data co-located with model via extension):**

```swift
extension Friend {
    static let sampleData = [
        Friend(name: "Elena", birthday: Date(timeIntervalSince1970: 0)),
        Friend(name: "Graham", birthday: Date(timeIntervalSince1970: 86400)),
        Friend(name: "Jaya", birthday: Date(timeIntervalSince1970: 172800))
    ]
}

// Usage in SampleData singleton:
for friend in Friend.sampleData {
    context.insert(friend)
}
```

**When NOT to use:**
- Models with complex relationship graphs where sample data requires multiple interdependent inserts — use a dedicated factory method instead

**Benefits:**
- When a model property changes, the compiler flags the sample data immediately
- Discoverable via autocomplete: `Friend.sampleData`
- Single array reused by previews, unit tests, and UI tests

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
