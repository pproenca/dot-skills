---
title: Dismiss Modal After ViewModel Save Completes
impact: MEDIUM
impactDescription: prevents 100% data loss when user dismisses before save completes
tags: crud, dismiss, save, modal, viewmodel
---

## Dismiss Modal After ViewModel Save Completes

Use `@Environment(\.dismiss)` to close sheets after the ViewModel confirms a successful save. The ViewModel calls the repository's `save()` method and sets a `isSaved` flag. The view observes this flag and dismisses. This ensures the user is never dismissed before their data is persisted.

**Incorrect (dismiss without confirming save — may lose data):**

```swift
@Equatable
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FriendEditorViewModel

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                    dismiss() // Dismisses immediately — save may not have completed
                }
            }
        }
    }
}
```

**Correct (dismiss only after save confirms):**

```swift
@Equatable
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FriendEditorViewModel

    init(friend: Friend, friendRepository: FriendRepository) {
        _viewModel = State(initialValue: FriendEditorViewModel(
            friend: friend, isNew: true, friendRepository: friendRepository
        ))
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
            }
        }
        .onChange(of: viewModel.isSaved) { _, saved in
            if saved { dismiss() }
        }
    }
}
```

**Reconciliation with autosave:** If your repository implementation relies on SwiftData autosave (no explicit `context.save()`), the repository `save()` method should still explicitly call `context.save()` to ensure data is flushed before returning. For flows where autosave is acceptable (e.g., editing existing records with @Bindable), dismiss immediately — but only if you have verified autosave is enabled on the container. See [`crud-save-error-handling`](crud-save-error-handling.md) for the error handling pattern.

**Benefits:**
- User data is confirmed persisted before the modal closes
- Async save completion prevents race conditions
- Clean separation: ViewModel owns the save lifecycle, view owns the dismiss

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
