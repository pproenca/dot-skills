---
title: Every Use Case Is a Protocol With a Single Execute Method
impact: HIGH
impactDescription: protocol boundary enables testing and enforces single responsibility
tags: layer, usecase, protocol, single-responsibility, interactor
---

## Every Use Case Is a Protocol With a Single Execute Method

Each use case represents one specific business operation. Define it as a protocol with a single async `execute()` method. The concrete implementation lives in the Domain layer but depends only on repository protocols. ViewModels call use cases — never repositories directly. This enforces single responsibility and makes every business operation independently testable.

**Incorrect (ViewModel calling repositories directly, multi-method use case — violates SRP):**

```swift
// Multi-purpose "service" with many methods — unclear responsibility
// Not a protocol — cannot be mocked for testing
class UserService {
    private let apiClient: APIClient
    private let database: Database

    // 5 different operations in one class — violates single responsibility
    func fetchUsers() async throws -> [User] { /* ... */ }
    func fetchUser(id: String) async throws -> User { /* ... */ }
    func updateUser(_ user: User) async throws { /* ... */ }
    func deleteUser(id: String) async throws { /* ... */ }
    func searchUsers(query: String) async throws -> [User] { /* ... */ }
}

// ViewModel directly calling repository — bypasses business logic layer
@Observable
final class UserListViewModel {
    private let userRepository: RemoteUserRepository  // Concrete type, not protocol

    var users: [User] = []

    func loadUsers() async {
        // Direct repository call — no place for business rules
        // What about filtering? Sorting? Caching logic? Pagination?
        users = try? await userRepository.fetchAll()
    }
}
```

**Correct (single-method protocol per use case — testable, single responsibility):**

```swift
// Domain/UseCases/FetchUsersUseCase.swift

// One protocol = one business operation
protocol FetchUsersUseCase: Sendable {
    func execute() async throws -> [User]
}

// Implementation depends only on repository protocols
final class FetchUsersUseCaseImpl: FetchUsersUseCase {
    private let userRepository: UserRepository  // Protocol, not concrete type

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> [User] {
        let users = try await userRepository.fetchAll()
        // Business rules applied here — not in view or repository
        return users
            .filter { $0.isActive }
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}

// Domain/UseCases/SearchUsersUseCase.swift

// Separate use case for search — different business rules
protocol SearchUsersUseCase: Sendable {
    func execute(query: String) async throws -> [User]
}

final class SearchUsersUseCaseImpl: SearchUsersUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(query: String) async throws -> [User] {
        guard query.count >= 2 else { return [] }  // Business rule: min query length
        return try await userRepository.search(query: query)
    }
}

// ViewModel calls use cases — never repositories
@Observable
final class UserListViewModel {
    private let fetchUsersUseCase: FetchUsersUseCase
    private let searchUsersUseCase: SearchUsersUseCase

    var users: [User] = []

    init(
        fetchUsersUseCase: FetchUsersUseCase,
        searchUsersUseCase: SearchUsersUseCase
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.searchUsersUseCase = searchUsersUseCase
    }

    func loadUsers() async {
        users = (try? await fetchUsersUseCase.execute()) ?? []
    }

    func search(query: String) async {
        users = (try? await searchUsersUseCase.execute(query: query)) ?? []
    }
}

// Testing — mock use case, no real repository needed
struct MockFetchUsersUseCase: FetchUsersUseCase {
    var stubbedResult: [User] = []

    func execute() async throws -> [User] {
        stubbedResult
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
