---
title: Use @Query for Declarative Data Fetching (Data Layer)
impact: HIGH
impactDescription: automatic view updates when data changes, zero boilerplate
tags: query, property-wrapper, swiftui, swiftdata, data-layer
---

## Use @Query for Declarative Data Fetching (Data Layer)

`@Query` fetches SwiftData entities and automatically updates the view when underlying data changes — no `onAppear`, `NotificationCenter`, or manual refresh logic needed. Manual fetching with `context.fetch()` in views misses updates, requires extra state management, and inevitably produces stale UI states.

**Architecture note:** In Clean MVVM architecture, `@Query` and `FetchDescriptor` are Data layer implementation details — they belong in repository implementations, not in views or ViewModels. Views read data from `@Observable` ViewModels, which read from repository protocols. See [`state-query-vs-viewmodel`](state-query-vs-viewmodel.md) for the recommended architecture and [`persist-repository-wrapper`](persist-repository-wrapper.md) for the repository pattern.

**Incorrect (manual fetch misses live updates):**

```swift
@Equatable
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
@Equatable
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

**Known limitation — cross-context inserts:**
`@Query` does not reliably update when data is inserted from a `@ModelActor` background context. Deletes propagate correctly, but inserts and updates from background actors may leave the UI stale until the next autosave merge. If your app uses background imports or sync services, see [`query-background-refresh`](query-background-refresh.md) for the workaround pattern using `ModelContext.didSave` notifications.

**When NOT to use:**
- In non-SwiftUI contexts (background tasks, services, unit tests) — use `FetchDescriptor` with `context.fetch()` instead
- When you need a one-shot fetch that should not trigger view re-renders

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
