---
title: Views Never Access Repositories Directly
impact: HIGH
impactDescription: reduces view-data coupling by enforcing a single ViewModel boundary
tags: layer, view, repository, boundary, viewmodel
---

## Views Never Access Repositories Directly

Views access data through ViewModels. ViewModels call Domain repository protocols. Views must not call `ModelContext`, `@Query`, repositories, or network clients directly.

**Incorrect (view contains data access):**

```swift
struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    let userID: UUID

    var body: some View {
        Text("Profile")
            .task {
                let descriptor = FetchDescriptor<UserEntity>(
                    predicate: #Predicate { $0.id == userID }
                )
                _ = try? modelContext.fetch(descriptor)
            }
    }
}
```

**Correct (View -> ViewModel -> Repository):**

```swift
protocol UserRepository: Sendable {
    func get(id: UUID) async throws -> User?
}

@Observable
final class UserProfileViewModel {
    private let userRepository: any UserRepository

    var user: User?
    var isLoading = false

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func load(id: UUID) async {
        isLoading = true
        defer { isLoading = false }
        user = try? await userRepository.get(id: id)
    }
}

struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel
    let userID: UUID

    var body: some View {
        Group {
            if let user = viewModel.user {
                Text(user.name)
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
        .task { await viewModel.load(id: userID) }
    }
}
```
