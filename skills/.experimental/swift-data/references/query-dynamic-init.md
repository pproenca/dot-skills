---
title: Use Custom View Initializers for Dynamic Queries
impact: MEDIUM-HIGH
impactDescription: enables search and filter UI without losing @Query auto-updates
tags: query, dynamic, initializer, search
---

## Use Custom View Initializers for Dynamic Queries

`@Query` parameters are fixed at init time. To enable dynamic filtering (e.g., from a search bar or picker), create a child view with a custom initializer that constructs the `Query` from parameters passed by the parent. This preserves automatic view updates while allowing runtime filter changes.

**Incorrect (filtering @Query results in the view body):**

```swift
struct FriendList: View {
    @Query(sort: \Friend.name) private var friends: [Friend]
    var searchText: String

    var body: some View {
        // Filters in memory — defeats the purpose of @Query optimization
        let filtered = searchText.isEmpty
            ? friends
            : friends.filter { $0.name.contains(searchText) }
        List(filtered) { friend in
            Text(friend.name)
        }
    }
}
```

**Correct (custom init constructs @Query dynamically):**

```swift
struct FriendList: View {
    @Query private var friends: [Friend]

    init(titleFilter: String = "") {
        if titleFilter.isEmpty {
            _friends = Query(sort: \.name)
        } else {
            let predicate = #Predicate<Friend> { friend in
                friend.name.localizedStandardContains(titleFilter)
            }
            _friends = Query(filter: predicate, sort: \.name)
        }
    }

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}

// Parent view drives the filter
struct ContentView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            FriendList(titleFilter: searchText)
                .searchable(text: $searchText)
        }
    }
}
```

**When NOT to use:**
- If the query never changes at runtime, a simple `@Query` declaration is sufficient
- For one-time fetches in background tasks, use `FetchDescriptor` instead

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
