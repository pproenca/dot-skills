---
title: Access ModelContext via @Environment for Mutations
impact: MEDIUM
impactDescription: reduces context plumbing and helps avoid accidental wrong-context mutations
tags: state, environment, model-context, mutations
---

## Access ModelContext via @Environment for Mutations

Prefer `@Environment(\.modelContext)` in any view that performs inserts, deletes, or edits. The model container you set on the scene/view hierarchy provides a consistent, main-actor `ModelContext` throughout the subtree. Passing `ModelContext` through view initializers isn't inherently wrong, but it increases coupling and makes it easier to accidentally mutate with the wrong context after refactors.

**Incorrect (threading context through views — extra coupling and fragile plumbing):**

```swift
struct FriendList: View {
    let context: ModelContext // Must be threaded from parent
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .toolbar {
            Button("Add") {
                context.insert(Friend(name: "New Friend", birthday: .now))
            }
        }
    }
}

// Parent must thread context through every navigation level.
struct ContentView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        FriendList(context: context) // Fragile dependency passing
    }
}
```

**Correct (@Environment in any view that needs mutations):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .toolbar {
            Button("Add") {
                context.insert(Friend(name: "New Friend", birthday: .now))
            }
        }
    }
}
```

**When NOT to use:**
- Non-View code (services, repositories, background tasks) can accept a `ModelContext` as a dependency to keep SwiftUI out of the data layer

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
