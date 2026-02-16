---
title: Avoid Orphaned Records by Persisting Only on Save
impact: HIGH
impactDescription: prevents orphaned empty records in the database
tags: crud, cancel, delete, modal, data-integrity, architecture
---

## Avoid Orphaned Records by Persisting Only on Save

In Clean Architecture, the creation form works with a domain struct in memory. Persistence only happens when the user confirms via the ViewModel and repository. Cancellation discards the in-memory struct — no cleanup needed. This eliminates the orphaned-record problem that arises when inserting entities before the form is complete.

**Incorrect (insert-before-present pattern — orphaned records on cancel):**

```swift
@Equatable
struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var friend: FriendEntity
    var isNew: Bool

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if isNew {
                        context.delete(friend) // Must clean up orphaned entity
                    }
                    dismiss()
                }
            }
        }
    }
}
```

**Correct (domain struct in memory until save — no orphaned records):**

```swift
@Observable
final class FriendEditorViewModel {
    private let friendRepository: FriendRepository

    var friend: Friend
    var isSaved = false
    let isNew: Bool

    init(friend: Friend, isNew: Bool, friendRepository: FriendRepository) {
        self.friend = friend
        self.isNew = isNew
        self.friendRepository = friendRepository
    }

    func save() async throws {
        try await friendRepository.save(friend)
        isSaved = true
    }
}

@Equatable
struct FriendEditorView: View {
    @State private var viewModel: FriendEditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(friend: Friend, isNew: Bool, friendRepository: FriendRepository) {
        _viewModel = State(initialValue: FriendEditorViewModel(
            friend: friend, isNew: isNew, friendRepository: friendRepository
        ))
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.friend.name)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss() // No cleanup — nothing was persisted
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        try? await viewModel.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
```

**When NOT to use:**
- When editing an existing model — cancellation should revert changes (reload from repository or use undo manager)

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
