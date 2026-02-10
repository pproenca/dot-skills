---
title: Insert Models via ModelContext
impact: HIGH
impactDescription: ensures model instances are tracked by SwiftData for persistence
tags: crud, insert, model-context, persistence
---

## Insert Models via ModelContext

Creating a model instance with `Friend(name: "x")` only allocates it in memory. You must call `context.insert()` to register it with SwiftData for persistence. Without this step, the model vanishes when the app relaunches.

**Incorrect (model created but never persisted):**

```swift
struct AddFriendView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        Button("Add Friend") {
            // Created in memory only — never saved to the database
            let friend = Friend(name: "New Friend")
            // friend is lost when the view disappears
        }
    }
}
```

**Correct (model inserted into context for persistence):**

```swift
struct AddFriendView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        Button("Add Friend") {
            let friend = Friend(name: "New Friend")
            context.insert(friend) // Now tracked by SwiftData and persisted
        }
    }
}
```

**When NOT to use:**
- Temporary objects used only for computation that should never be saved
- Preview or test data that uses an in-memory model container (insertion still works but data is discarded)

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
