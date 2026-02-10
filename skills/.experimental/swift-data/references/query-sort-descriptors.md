---
title: Apply Sort Descriptors to @Query
impact: HIGH
impactDescription: ensures stable, user-friendly list ordering across app launches
tags: query, sorting, sort-descriptor, stability
---

## Apply Sort Descriptors to @Query

Without explicit sorting, `@Query` returns items in undefined order that changes between app launches. Users see items shuffle randomly, creating a confusing experience. Always specify a sort key path for deterministic ordering.

**Incorrect (undefined order changes on every launch):**

```swift
struct FriendList: View {
    // Order is unpredictable — items shuffle between launches
    @Query private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}
```

**Correct (explicit sort for stable ordering):**

```swift
struct FriendList: View {
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}
```

**Alternative:**

For multiple sort criteria or descending order, use an array of `SortDescriptor`:

```swift
@Query(sort: [
    SortDescriptor(\Friend.name),
    SortDescriptor(\Friend.birthday, order: .reverse)
]) private var friends: [Friend]
```

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
