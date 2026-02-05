---
title: Add Swipe Actions to List Rows
impact: MEDIUM-HIGH
impactDescription: familiar iOS interaction pattern, quick actions, proper delete confirmation
tags: list, swiftui, list, swipe-actions, delete, gestures
---

## Add Swipe Actions to List Rows

Use `.swipeActions()` modifier to add swipe-to-reveal actions on list rows. Use `.onDelete()` for standard delete swipe with Edit mode support.

**Incorrect (custom swipe gesture implementation):**

```swift
// Don't implement custom swipe gestures for standard actions
List(friends) { friend in
    Text(friend.name)
        .gesture(DragGesture()...)  // Complex and non-standard
}
```

**Correct (built-in swipe actions):**

```swift
// Simple delete with onDelete
struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete(perform: deleteFriends)
        }
    }

    private func deleteFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
    }
}

// Custom swipe actions
List(friends) { friend in
    Text(friend.name)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(friend)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                friend.isFavorite.toggle()
            } label: {
                Label("Favorite", systemImage: "star")
            }
            .tint(.yellow)
        }
}
```

**Swipe action patterns:**
- `.onDelete()` enables Edit mode and swipe-to-delete
- `.swipeActions(edge:)` for custom actions
- Use `role: .destructive` for delete actions
- Leading edge for positive actions, trailing for destructive

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
