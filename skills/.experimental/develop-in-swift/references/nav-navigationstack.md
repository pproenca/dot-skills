---
title: Use NavigationStack for Hierarchical Navigation
impact: HIGH
impactDescription: modern push/pop navigation, type-safe destinations, programmatic control
tags: nav, swiftui, navigation, navigationstack, push, ios16
---

## Use NavigationStack for Hierarchical Navigation

`NavigationStack` (iOS 16+) provides hierarchical navigation with push/pop behavior. Use `NavigationLink` with `value:` for type-safe navigation and `navigationDestination` to define where each type navigates to.

**Incorrect (deprecated NavigationView):**

```swift
// Old pattern - deprecated
NavigationView {
    List(friends) { friend in
        NavigationLink(destination: FriendDetail(friend: friend)) {
            Text(friend.name)
        }
    }
}
```

**Correct (NavigationStack with typed destinations):**

```swift
struct FriendListView: View {
    @Query private var friends: [Friend]

    var body: some View {
        NavigationStack {
            List(friends) { friend in
                NavigationLink(value: friend) {
                    Text(friend.name)
                }
            }
            .navigationTitle("Friends")
            .navigationDestination(for: Friend.self) { friend in
                FriendDetailView(friend: friend)
            }
        }
    }
}

// Multiple destination types
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Friends", value: Route.friends)
                NavigationLink("Movies", value: Route.movies)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .friends: FriendListView()
                case .movies: MovieListView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case friends
    case movies
}
```

**NavigationStack features:**
- Type-safe navigation with `value:` parameter
- `navigationDestination(for:)` defines destinations
- Programmatic navigation with `@State var path`
- Supports deep linking

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
