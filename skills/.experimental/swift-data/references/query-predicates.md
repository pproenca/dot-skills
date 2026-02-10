---
title: "Use #Predicate for Type-Safe Filtering"
impact: HIGH
impactDescription: compile-time checked filters prevent runtime crashes
tags: query, predicate, filtering, type-safety
---

## Use #Predicate for Type-Safe Filtering

`#Predicate` provides type-safe, compile-time checked filtering that SwiftData can optimize at the storage level. Manual in-memory filtering with `.filter()` bypasses SwiftData's query optimizer, loads all records into memory, and does not benefit from indexing.

**Incorrect (in-memory filtering after fetching all records):**

```swift
struct FriendList: View {
    @Query private var friends: [Friend]
    @State private var searchText = ""

    var body: some View {
        // Fetches ALL friends, then filters in memory — wasteful with large datasets
        let filtered = friends.filter { $0.name.contains(searchText) }
        List(filtered) { friend in
            Text(friend.name)
        }
    }
}
```

**Correct (predicate pushes filtering to SwiftData):**

```swift
struct FriendList: View {
    @Query private var friends: [Friend]

    init(searchText: String) {
        let predicate = #Predicate<Friend> { friend in
            friend.name.localizedStandardContains(searchText)
        }
        _friends = Query(filter: predicate, sort: \.name)
    }

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}
```

**Benefits:**
- Compile-time type checking catches typos in property names
- SwiftData can use indexes to speed up filtering
- Only matching records are loaded into memory

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
