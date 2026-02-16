---
title: Sort Relationship Arrays Explicitly
impact: MEDIUM
impactDescription: prevents unstable ordering in relationship-backed lists
tags: rel, sorting, array, display, stability
---

## Sort Relationship Arrays Explicitly

Relationship arrays (e.g., `movie.favoritedBy`) have no guaranteed order. SwiftData may return elements in insertion order, but this is not contractual and can change after background saves or migration. Displaying an unsorted relationship array in a `ForEach` produces unpredictable ordering that shifts between renders, confusing users.

**Incorrect (unsorted relationship array — random order on every render):**

```swift
@Equatable
struct MovieDetail: View {
    var movie: Movie

    var body: some View {
        List {
            Section("Favorited By") {
                // Order may change between renders — unstable UI
                ForEach(movie.favoritedBy) { friend in
                    Text(friend.name)
                }
            }
        }
    }
}
```

**Correct (explicitly sorted before display):**

```swift
@Equatable
struct MovieDetail: View {
    var movie: Movie

    var body: some View {
        List {
            Section("Favorited By") {
                ForEach(movie.favoritedBy.sorted(by: { $0.name < $1.name })) { friend in
                    Text(friend.name)
                }
            }
        }
    }
}
```

**Alternative:**
- For large arrays, compute the sorted result in a computed property or cache it to avoid re-sorting on every view evaluation:

```swift
private var sortedFriends: [Friend] {
    movie.favoritedBy.sorted(by: { $0.name < $1.name })
}
```

Reference: [Develop in Swift — Work with Relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)
