---
title: Delete via Repository with IndexSet from onDelete Modifier
impact: HIGH
impactDescription: prevents orphaned records — swipe-to-delete removes from database, not just UI
tags: crud, delete, indexset, ondelete, list, data-layer
---

## Delete via Repository with IndexSet from onDelete Modifier

SwiftUI's `.onDelete` modifier provides the standard swipe-to-delete gesture for list rows. It passes an `IndexSet` mapping to the `ForEach` data source. The view delegates the delete operation to the ViewModel, which calls the repository. The repository handles `ModelContext.delete()` in the Data layer.

**Incorrect (view deletes from ModelContext directly — persistence logic in presentation):**

```swift
@Equatable
struct FriendList: View {
    @Query(sort: \FriendEntity.name) private var friends: [FriendEntity]
    @Environment(\.modelContext) private var context

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete { offsets in
                for index in offsets {
                    context.delete(friends[index]) // Data layer logic in view
                }
            }
        }
    }
}
```

**Correct (View -> ViewModel -> Repository — clean deletion flow):**

```swift
@Observable
final class FriendListViewModel {
    private let friendRepository: FriendRepository

    var friends: [Friend] = []
    var errorMessage: String?

    init(friendRepository: FriendRepository) {
        self.friendRepository = friendRepository
    }

    func loadFriends() async {
        friends = (try? await friendRepository.fetchAll()) ?? []
    }

    func deleteFriends(at offsets: IndexSet) async {
        let idsToDelete = offsets.map { friends[$0].id }
        friends.remove(atOffsets: offsets) // Optimistic UI update
        for id in idsToDelete {
            do {
                try await friendRepository.delete(id: id)
            } catch {
                errorMessage = error.localizedDescription
                await loadFriends() // Revert on failure
            }
        }
    }
}

@Equatable
struct FriendList: View {
    @State private var viewModel: FriendListViewModel

    init(friendRepository: FriendRepository) {
        _viewModel = State(initialValue: FriendListViewModel(friendRepository: friendRepository))
    }

    var body: some View {
        List {
            ForEach(viewModel.friends) { friend in
                Text(friend.name)
            }
            .onDelete { offsets in
                Task { await viewModel.deleteFriends(at: offsets) }
            }
        }
        .task { await viewModel.loadFriends() }
    }
}
```

**Benefits:**
- Provides the familiar iOS swipe-to-delete interaction
- Optimistic UI update keeps the interface responsive
- Repository handles persistence — view only handles layout
- Delete errors are surfaced to the user, not silently ignored

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
