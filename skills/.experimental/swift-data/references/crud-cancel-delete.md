---
title: Delete Unsaved Models on Cancel
impact: HIGH
impactDescription: prevents orphaned empty records in the database
tags: crud, cancel, delete, modal, data-integrity
---

## Delete Unsaved Models on Cancel

When creating a new model, you insert it into the context before presenting the form so that `@Bindable` can bind to its properties. If the user cancels, you must delete that model from the context. Otherwise an empty or incomplete record persists in the database.

**Incorrect (cancel leaves an empty record in the database):**

```swift
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var friend: Friend
    var isNew: Bool

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    // Empty Friend record stays in the database forever
                    dismiss()
                }
            }
        }
    }
}
```

**Correct (cancel deletes the incomplete model):**

```swift
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var friend: Friend
    var isNew: Bool

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if isNew {
                        context.delete(friend) // Remove incomplete record
                    }
                    dismiss()
                }
            }
        }
    }
}
```

**When NOT to use:**
- When editing an existing model (not a new creation) — cancellation should revert changes, not delete the record
- If using a child context or undo manager for transactional editing

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
