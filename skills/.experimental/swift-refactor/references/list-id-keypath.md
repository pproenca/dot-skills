---
title: Provide Explicit id KeyPath — Never Rely on Implicit Identity
impact: MEDIUM
impactDescription: prevents silent identity collisions that cause missing or duplicated rows
tags: list, id, keypath, foreach, identifiable
---

## Provide Explicit id KeyPath — Never Rely on Implicit Identity

When `ForEach` infers identity from `Identifiable` conformance, a model change (like switching from UUID to database ID) can silently break list diffing. Using `id: \.self` on non-unique values (like `String` or `Int`) causes collisions where duplicate values render only once. Always provide an explicit `id` keyPath to make the identity source visible and intentional.

**Incorrect (id: \.self on non-unique values — collisions):**

```swift
struct CategoryPicker: View {
    let categories: [String]

    var body: some View {
        ForEach(categories, id: \.self) { category in
            // "Electronics" appearing twice renders only once
            // SwiftUI drops the "duplicate" identity
            Text(category)
        }
    }
}
```

**Correct (explicit id keyPath on unique property):**

```swift
struct Category: Identifiable, Equatable {
    let id: UUID
    let name: String
}

struct CategoryPicker: View {
    let categories: [Category]

    var body: some View {
        ForEach(categories, id: \.id) { category in
            // Explicit keyPath — identity source is visible and unique
            Text(category.name)
        }
    }
}
```

**Correct (Identifiable conformance with explicit id):**

```swift
struct CategoryPicker: View {
    let categories: [Category]

    var body: some View {
        // Identifiable provides id automatically
        // But the model must guarantee uniqueness
        ForEach(categories) { category in
            Text(category.name)
        }
    }
}
```

Reference: [Demystify SwiftUI — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10022/)
