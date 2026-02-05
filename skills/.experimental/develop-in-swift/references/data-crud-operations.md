---
title: Perform CRUD with modelContext
impact: HIGH
impactDescription: insert, update, delete models; automatic saves; transaction support
tags: data, swiftdata, crud, insert, delete, modelcontext
---

## Perform CRUD with modelContext

Use the model context from `@Environment(\.modelContext)` to insert and delete SwiftData models. Updates happen automatically when you modify model properties. SwiftData saves changes automatically.

**Incorrect (manual save calls or wrong patterns):**

```swift
// Don't create models without inserting
let friend = Friend(name: "Sophie")
// friend exists but isn't persisted!

// Don't try to manually save
modelContext.save()  // Usually unnecessary
```

**Correct (proper CRUD operations):**

```swift
import SwiftData
import SwiftUI

struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete(perform: deleteFriends)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                addFriend()
            }
        }
    }

    // CREATE
    private func addFriend() {
        let friend = Friend(name: "New Friend")
        modelContext.insert(friend)
        // SwiftData auto-saves
    }

    // DELETE
    private func deleteFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
    }
}

// UPDATE - just modify properties
struct FriendDetailView: View {
    @Bindable var friend: Friend  // @Bindable for binding to model properties

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
            // Changes auto-save when you type
        }
    }
}
```

**CRUD operations:**
- **Create**: `modelContext.insert(model)`
- **Read**: `@Query` fetches automatically
- **Update**: Modify model properties directly
- **Delete**: `modelContext.delete(model)`

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
