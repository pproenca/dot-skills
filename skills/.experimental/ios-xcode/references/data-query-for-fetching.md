---
title: Use @Query to Fetch SwiftData Models
impact: CRITICAL
impactDescription: reactive data fetching, automatic UI updates, type-safe predicates
tags: data, swiftdata, query, fetching, reactive, swiftui
---

## Use @Query to Fetch SwiftData Models

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

`@Query` fetches SwiftData models and automatically updates your view when data changes. It's the primary way to display persisted data in SwiftUI. Add sorting and filtering with predicates.

**Incorrect (manual fetching):**

```swift
// Don't manually fetch in onAppear
struct FriendListView: View {
    @State private var friends: [Friend] = []

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .onAppear {
            // Manual fetching won't update when data changes
            friends = fetchFriends()
        }
    }
}
```

**Correct (@Query for reactive fetching):**

```swift
import SwiftData
import SwiftUI

struct FriendListView: View {
    @Query private var friends: [Friend]  // Automatically fetches all Friends

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}

// With sorting
struct FriendListView: View {
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}

// With filtering and sorting
struct FavoritesView: View {
    @Query(
        filter: #Predicate<Movie> { $0.isFavorite },
        sort: \Movie.title
    ) private var favorites: [Movie]

    var body: some View {
        List(favorites) { movie in
            Text(movie.title)
        }
    }
}
```

**@Query features:**
- Automatically re-fetches when data changes
- Sort with key paths: `sort: \Model.property`
- Filter with `#Predicate` macro
- Combine multiple sort descriptors
- Results are always up-to-date

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
