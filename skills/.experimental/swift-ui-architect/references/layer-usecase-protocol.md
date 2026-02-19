---
title: Do Not Add a Dedicated Use-Case Layer
impact: HIGH
impactDescription: removes boilerplate and keeps feature flow aligned with modular MVVM-C
tags: layer, architecture, repository, viewmodel, modular-mvvm-c
---

## Do Not Add a Dedicated Use-Case Layer

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

In the clinic architecture, ViewModels call Domain repository protocols directly. Avoid adding a separate use-case/interactor layer unless a cross-feature workflow is truly shared and reused. The default flow is: `View -> ViewModel -> Repository protocol`.

**Incorrect (extra layer with no reuse):**

```swift
protocol FetchUsersUseCase {
    func execute() async throws -> [User]
}

final class FetchUsersUseCaseImpl: FetchUsersUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> [User] {
        try await userRepository.fetchAll()
    }
}

@Observable
final class UserListViewModel {
    private let fetchUsersUseCase: FetchUsersUseCase
    var users: [User] = []

    init(fetchUsersUseCase: FetchUsersUseCase) {
        self.fetchUsersUseCase = fetchUsersUseCase
    }

    func loadUsers() async {
        users = (try? await fetchUsersUseCase.execute()) ?? []
    }
}
```

**Correct (ViewModel calls repository protocol directly):**

```swift
protocol UserRepository: Sendable {
    func fetchAll() async throws -> [User]
    func delete(id: UUID) async throws
}

@Observable
final class UserListViewModel {
    private let userRepository: any UserRepository
    var users: [User] = []

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func loadUsers() async {
        users = (try? await userRepository.fetchAll()) ?? []
    }

    func delete(_ id: UUID) async {
        do {
            try await userRepository.delete(id: id)
            users.removeAll { $0.id == id }
        } catch {
            // Route through ErrorRouting at feature level.
        }
    }
}
```

Keep complex domain rules in Domain models and repository implementations, not in a default use-case layer.
