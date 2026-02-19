---
title: Access ModelContext via @Environment (Data Layer)
impact: HIGH
impactDescription: using wrong context causes data to save to the wrong store or not at all
tags: persist, model-context, environment, swiftdata, data-layer
---

## Access ModelContext via @Environment (Data Layer)

Within the Data layer, always access the `ModelContext` through the container you set up at the app level. Creating your own context without proper configuration leads to data saving to a separate store that the rest of your app never reads.

**Architecture note:** In modular MVVM-C, `ModelContext` is a Data-layer concern. It belongs in repository implementations, not in feature views or ViewModels. Views access data through `@Observable` ViewModels backed by repository protocols. See [`persist-repository-wrapper`](persist-repository-wrapper.md) for the repository pattern and [`state-dependency-injection`](state-dependency-injection.md) for injecting repositories via `@Environment`.

**Incorrect (manually created context — separate store):**

```swift
@Equatable
struct FriendListView: View {
    // Creates a completely separate store — data saved here is invisible to @Query
    let context = try! ModelContext(ModelContainer(for: Friend.self))

    var body: some View {
        Button("Add Friend") {
            let friend = Friend(name: "Alex", birthday: .now)
            context.insert(friend)
            // Saved to a different database file — won't appear in the app's queries
        }
    }
}
```

**Correct (environment-provided context):**

```swift
@Equatable
struct FriendListView: View {
    @Environment(\.modelContext) private var context
    @Query private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        Button("Add Friend") {
            let friend = Friend(name: "Alex", birthday: .now)
            context.insert(friend)
            // Uses the same store as @Query — friend appears in the list immediately
        }
    }
}
```

**When NOT to use:**
- Background tasks that need their own context should create one from the shared container: `ModelContext(container)` — but pass the same container, not a new one
- Non-View code (services, repositories, background tasks) can accept a `ModelContext` as a dependency to keep SwiftUI out of the data layer

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
