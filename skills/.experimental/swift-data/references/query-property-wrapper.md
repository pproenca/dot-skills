---
title: Use @Query for Declarative Data Fetching
impact: HIGH
impactDescription: automatic view updates when data changes, zero boilerplate
tags: query, property-wrapper, swiftui, swiftdata
---

## Use @Query for Declarative Data Fetching

`@Query` fetches SwiftData models and automatically updates the view when underlying data changes — no `onAppear`, `NotificationCenter`, or manual refresh logic needed. Manual fetching with `context.fetch()` in views misses updates, requires extra state management, and inevitably produces stale UI states.

**Incorrect (manual fetch misses live updates):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @State var friends: [Friend] = []

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .onAppear {
            // Must be called manually; view never updates when data changes elsewhere
            friends = (try? context.fetch(FetchDescriptor<Friend>())) ?? []
        }
    }
}
```

**Correct (declarative @Query with automatic updates):**

```swift
struct FriendList: View {
    @Query private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        // No onAppear needed — view updates automatically when friends change
    }
}
```

**When NOT to use:**
- In non-SwiftUI contexts (background tasks, services, unit tests) — use `FetchDescriptor` with `context.fetch()` instead
- When you need a one-shot fetch that should not trigger view re-renders

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
