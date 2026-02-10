---
title: Enable Autosave for Manually Created Contexts
impact: HIGH
impactDescription: manual contexts don't save automatically — data lost on app quit
tags: persist, autosave, model-context, data-loss
---

## Enable Autosave for Manually Created Contexts

The environment-provided `ModelContext` has autosave enabled by default — changes are persisted automatically at appropriate intervals. However, if you create a context manually (for background work or batch operations), autosave is disabled. You must either enable it or call `try context.save()` explicitly, or all inserted data is lost when the app quits.

**Incorrect (manual context without save — data lost):**

```swift
func importFriends(from data: [FriendData], container: ModelContainer) {
    let context = ModelContext(container)

    for item in data {
        let friend = Friend(name: item.name, birthday: item.birthday)
        context.insert(friend)
    }
    // Context is deallocated — all inserts are lost
    // No autosave, no explicit save
}
```

**Correct (explicit save or autosave enabled):**

```swift
// Option 1: Explicit save
func importFriends(from data: [FriendData], container: ModelContainer) throws {
    let context = ModelContext(container)

    for item in data {
        let friend = Friend(name: item.name, birthday: item.birthday)
        context.insert(friend)
    }
    try context.save()  // Persists all changes immediately
}

// Option 2: Enable autosave
func importFriends(from data: [FriendData], container: ModelContainer) {
    let context = ModelContext(container)
    context.autosaveEnabled = true  // SwiftData will save automatically

    for item in data {
        let friend = Friend(name: item.name, birthday: item.birthday)
        context.insert(friend)
    }
}
```

**When NOT to use:**
- The `@Environment(\.modelContext)` context already has autosave — no action needed
- For batch imports where you want to validate before committing, keep autosave off and call `save()` only after validation passes

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
