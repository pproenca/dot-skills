---
title: Use Sheets for Focused Data Creation via ViewModel
impact: MEDIUM
impactDescription: prevents accidental navigation away from incomplete data entry
tags: crud, sheet, modal, creation, ux, viewmodel
---

## Use Sheets for Focused Data Creation via ViewModel

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Present new item creation in a sheet rather than pushing a navigation view. Sheets keep users focused on the creation task and provide a clear Save/Cancel flow. The ViewModel manages creation state and delegates persistence to the repository. Combined with `.interactiveDismissDisabled()`, sheets prevent accidental dismissal.

**Incorrect (view creates and inserts entity directly — persistence logic in presentation):**

```swift
@Equatable
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FriendEntity.name) private var friends: [FriendEntity]
    @State private var newFriend: FriendEntity?

    var body: some View {
        NavigationStack {
            List(friends) { friend in
                Text(friend.name)
            }
            .toolbar {
                Button("Add Friend") {
                    let friend = FriendEntity(name: "")
                    context.insert(friend) // Data layer logic in view
                    newFriend = friend
                }
            }
        }
    }
}
```

**Correct (ViewModel manages creation flow, repository handles persistence):**

```swift
@Observable
final class FriendListViewModel {
    private let friendRepository: FriendRepository
    var friends: [Friend] = []
    var isCreating = false
    var newFriend = Friend(id: UUID().uuidString, name: "", birthday: .now)

    init(friendRepository: FriendRepository) {
        self.friendRepository = friendRepository
    }

    func loadFriends() async {
        friends = (try? await friendRepository.fetchAll()) ?? []
    }

    func startCreation() {
        newFriend = Friend(id: UUID().uuidString, name: "", birthday: .now)
        isCreating = true
    }

    func saveNewFriend() async {
        try? await friendRepository.save(newFriend)
        isCreating = false
        await loadFriends()
    }

    func cancelCreation() {
        isCreating = false // No orphaned records — nothing was persisted yet
    }
}
```

```swift
@Equatable
struct FriendListView: View {
    @State private var viewModel: FriendListViewModel

    init(friendRepository: FriendRepository) {
        _viewModel = State(initialValue: FriendListViewModel(friendRepository: friendRepository))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.friends) { friend in
                Text(friend.name)
            }
            .toolbar {
                Button("Add Friend") { viewModel.startCreation() }
            }
            .sheet(isPresented: $viewModel.isCreating) {
                NavigationStack {
                    FriendEditorView(
                        friend: $viewModel.newFriend,
                        onSave: { Task { await viewModel.saveNewFriend() } },
                        onCancel: { viewModel.cancelCreation() }
                    )
                }
                .interactiveDismissDisabled()
            }
        }
        .task { await viewModel.loadFriends() }
    }
}
```

**Key advantage over insert-before-present:** The domain struct is created in memory without being persisted. Cancellation simply discards the struct — no orphaned records in the database, no cleanup needed.

**Benefits:**
- Clear modal context signals "you are creating something new"
- `.interactiveDismissDisabled()` prevents accidental swipe-to-dismiss
- Save/Cancel buttons provide explicit intent

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
