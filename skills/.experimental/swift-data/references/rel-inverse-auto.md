---
title: Rely on SwiftData Automatic Inverse Maintenance
impact: MEDIUM-HIGH
impactDescription: prevents relationship inconsistency and double-update bugs
tags: rel, inverse, automatic, swiftdata, consistency
---

## Rely on SwiftData Automatic Inverse Maintenance

When you set one side of a relationship (e.g., `friend.favoriteMovie = movie`), SwiftData automatically updates the inverse side (`movie.favoritedBy`). Manually maintaining both sides introduces bugs where a friend appears twice in `favoritedBy` or the relationship becomes inconsistent after undo operations.

**Incorrect (manually updating both sides — causes duplicates):**

```swift
func setFavorite(friend: Friend, movie: Movie) {
    friend.favoriteMovie = movie
    // BUG: SwiftData already added friend to movie.favoritedBy
    // This line adds a duplicate entry
    movie.favoritedBy.append(friend)
}
```

**Correct (set one side only — SwiftData handles the inverse):**

```swift
func setFavorite(friend: Friend, movie: Movie) {
    friend.favoriteMovie = movie
    // movie.favoritedBy now automatically includes this friend
}

func clearFavorite(friend: Friend) {
    friend.favoriteMovie = nil
    // friend is automatically removed from the movie's favoritedBy array
}
```

**When NOT to use:**
- If you define only one side of a relationship without a corresponding inverse property, there is no inverse to maintain — but this pattern is discouraged for data integrity

Reference: [Develop in Swift — Work with Relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)
