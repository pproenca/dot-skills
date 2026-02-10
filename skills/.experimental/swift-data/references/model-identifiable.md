---
title: Conform Models to Identifiable with UUID
impact: MEDIUM
impactDescription: prevents incorrect list diffing in ForEach for non-@Model types
tags: model, identifiable, uuid, swiftui
---

## Conform Models to Identifiable with UUID

SwiftUI's `ForEach` and `List` require stable identity to correctly diff and animate changes. Without `Identifiable` conformance backed by a `UUID`, items with the same display value collide and UI updates break. `@Model` classes get `Identifiable` automatically, but plain structs must add it explicitly.

**Incorrect (identity based on non-unique property):**

```swift
struct Player {
    var name: String
    var score: Int
}

// Two players named "Alex" will clash — SwiftUI can't tell them apart
ForEach(players, id: \.name) { player in
    Text("\(player.name): \(player.score)")
}
```

**Correct (UUID-backed Identifiable):**

```swift
struct Player: Identifiable {
    let id = UUID()
    var name: String
    var score: Int
}

// Each player has a unique id, even if names match
ForEach(players) { player in
    Text("\(player.name): \(player.score)")
}
```

**When NOT to use:**
- `@Model` classes already conform to `Identifiable` — no need to add it manually
- If an external API provides a guaranteed-unique ID (e.g., database primary key), use that instead of generating a new UUID

Reference: [Develop in Swift — Model Data with Custom Types](https://developer.apple.com/tutorials/develop-in-swift/model-data-with-custom-types)
