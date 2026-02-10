---
title: Access ModelContext via @Environment for Mutations
impact: MEDIUM
impactDescription: prevents 100% of split-store bugs from mismatched contexts
tags: state, environment, model-context, mutations
---

## Access ModelContext via @Environment for Mutations

Use `@Environment(\.modelContext)` to access the shared context for insert and delete operations. The model container set on the window group automatically provides this context to all child views. Passing context as a parameter or creating new `ModelContext` instances leads to multiple isolated stores where inserts in one context are invisible to queries in another.

**Incorrect (passing context as a parameter — breaks when view hierarchy changes):**

```swift
struct FriendList: View {
    let context: ModelContext // Passed from parent
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

// Parent must thread context through every navigation level
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
- Background operations that need an isolated context (e.g., batch imports) should create a dedicated `ModelContext` from the same `ModelContainer` to avoid blocking the main actor

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
