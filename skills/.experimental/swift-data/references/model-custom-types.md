---
title: Use Custom Types Over Parallel Arrays
impact: CRITICAL
impactDescription: prevents index-out-of-range crashes and data inconsistency
tags: model, custom-types, data-modeling, type-safety
---

## Use Custom Types Over Parallel Arrays

Modeling related properties in separate arrays (e.g., `[String]` for names, `[Int]` for scores) creates inconsistent states when one array is modified without the other. A single struct groups related data so it cannot go out of sync.

**Incorrect (parallel arrays drift out of sync):**

```swift
@Model class Leaderboard {
    var names: [String] = []
    var scores: [Int] = []

    func addPlayer(name: String) {
        names.append(name)
        // Forgot to append to scores — arrays are now different lengths
        // scores[names.count - 1] will crash with index out of range
    }
}
```

**Correct (custom type keeps data together):**

```swift
struct Player: Codable {
    var name: String
    var score: Int
}

@Model class Leaderboard {
    var players: [Player] = []

    func addPlayer(name: String, score: Int) {
        players.append(Player(name: name, score: score))
        // Impossible for name and score to go out of sync
    }
}
```

**Benefits:**
- Eliminates an entire class of index-out-of-range crashes
- Makes the data model self-documenting
- Simplifies iteration — `for player in players` vs. `for i in 0..<names.count`
- `Codable` conformance is required because SwiftData stores embedded value types as JSON blobs in the SQLite store

Reference: [Develop in Swift — Model Data with Custom Types](https://developer.apple.com/tutorials/develop-in-swift/model-data-with-custom-types)
