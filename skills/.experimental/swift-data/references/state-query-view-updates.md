---
title: Leverage @Query for Automatic View Updates
impact: MEDIUM
impactDescription: eliminates manual refresh logic and notification observers
tags: state, query, automatic-updates, reactive
---

## Leverage @Query for Automatic View Updates

`@Query` automatically observes changes to the underlying SwiftData store and triggers view re-renders whenever matching data changes. You never need to manually refresh, observe `NSManagedObjectContextDidSave` notifications, or call reload functions. Manual fetch patterns require complex lifecycle management and inevitably produce stale UI states.

**Incorrect (manual fetch with state — requires explicit refresh, often stale):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @State private var friends: [Friend] = []

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .onAppear {
            let descriptor = FetchDescriptor<Friend>(sortBy: [SortDescriptor(\.name)])
            friends = (try? context.fetch(descriptor)) ?? []
        }
        // BUG: List does not update when a friend is added or edited
        // Must manually re-fetch on every mutation — easy to forget
    }
}
```

**Correct (@Query — always current, zero refresh logic):**

```swift
struct FriendList: View {
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        // Automatically re-renders when friends are added, edited, or deleted
    }
}
```

**Benefits:**
- Zero boilerplate — no `onAppear`, no `NotificationCenter`, no manual state management
- View always reflects the current database state
- SwiftData optimizes re-renders to only the changed rows

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
