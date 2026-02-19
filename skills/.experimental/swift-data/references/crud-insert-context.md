---
title: Insert Models via ModelContext in Repository Implementations
impact: HIGH
impactDescription: prevents silent data loss — untracked models are never persisted
tags: crud, insert, model-context, persistence, data-layer
---

## Insert Models via ModelContext in Repository Implementations

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Creating an entity instance with `FriendEntity(name: "x")` only allocates it in memory. You must call `context.insert()` to register it with SwiftData for persistence. This operation belongs in repository implementations (Data layer), not in views or ViewModels.

**Incorrect (view inserts directly into ModelContext — bypasses architecture layers):**

```swift
@Equatable
struct AddFriendView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        Button("Add Friend") {
            let friend = FriendEntity(name: "New Friend")
            context.insert(friend) // Persistence logic in view — violates layer boundary
        }
    }
}
```

**Correct (repository handles insertion, ViewModel coordinates, view triggers):**

```swift
// Data/Repositories/SwiftDataFriendRepository.swift

final class SwiftDataFriendRepository: FriendRepository, @unchecked Sendable {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    func save(_ friend: Friend) async throws {
        let entity = FriendEntity(name: friend.name, birthday: friend.birthday)
        modelContainer.mainContext.insert(entity) // Data layer owns insert
        try modelContainer.mainContext.save()
    }
}

// Presentation/ViewModels/AddFriendViewModel.swift

@Observable
final class AddFriendViewModel {
    private let friendRepository: FriendRepository
    var isSaved = false

    init(friendRepository: FriendRepository) {
        self.friendRepository = friendRepository
    }

    func addFriend(name: String) async {
        let friend = Friend(id: UUID().uuidString, name: name, birthday: .now)
        try? await friendRepository.save(friend)
        isSaved = true
    }
}

// Presentation/Views/AddFriendView.swift

@Equatable
struct AddFriendView: View {
    @State private var viewModel: AddFriendViewModel

    init(friendRepository: FriendRepository) {
        _viewModel = State(initialValue: AddFriendViewModel(friendRepository: friendRepository))
    }

    var body: some View {
        Button("Add Friend") {
            Task { await viewModel.addFriend(name: "New Friend") }
        }
    }
}
```

**When NOT to use:**
- Temporary objects used only for computation that should never be saved
- Preview or test data that uses an in-memory model container

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
