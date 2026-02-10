---
title: Delete Using IndexSet with onDelete Modifier
impact: HIGH
impactDescription: ensures swipe-to-delete removes records from database, not just UI
tags: crud, delete, indexset, ondelete, list
---

## Delete Using IndexSet with onDelete Modifier

SwiftUI's `.onDelete` modifier provides the standard swipe-to-delete gesture for list rows. It passes an `IndexSet` mapping to the `ForEach` data source. You must delete from the model context, not from a local array, so SwiftData persists the removal.

**Incorrect (removes from local array, not from database):**

```swift
struct FriendList: View {
    @State private var friends: [Friend] = []

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete { offsets in
                // Only removes from the local array — record still in database
                friends.remove(atOffsets: offsets)
            }
        }
    }
}
```

**Correct (deletes from model context for persistent removal):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete { offsets in
                for index in offsets {
                    context.delete(friends[index])
                }
            }
        }
    }
}
```

**Benefits:**
- Provides the familiar iOS swipe-to-delete interaction
- SwiftData autosave ensures the deletion is persisted
- `@Query` automatically updates the list after deletion

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
