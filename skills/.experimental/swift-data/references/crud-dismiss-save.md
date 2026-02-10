---
title: Use Environment Dismiss for Modal Save Flow
impact: MEDIUM
impactDescription: avoids redundant save() calls when autosave is enabled
tags: crud, dismiss, save, modal, environment
---

## Use Environment Dismiss for Modal Save Flow

Use `@Environment(\.dismiss)` to close sheets after saving. Since SwiftData autosaves, changes made via `@Bindable` are already tracked by the model context. Simply dismissing the modal is sufficient to persist the data — no manual `context.save()` call is needed.

**Incorrect (manual save with custom dismiss logic):**

```swift
struct FriendDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var friend: Friend
    @Binding var isPresented: Bool

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Unnecessary — SwiftData autosaves
                    try? context.save()
                    isPresented = false
                }
            }
        }
    }
}
```

**Correct (environment dismiss with autosave):**

```swift
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var friend: Friend

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss() // SwiftData autosave handles persistence
                }
            }
        }
    }
}
```

**When NOT to use:**
- If you have explicitly disabled autosave on the model container — then you must call `context.save()` manually
- In batch import scenarios where you need precise control over when writes are flushed

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
