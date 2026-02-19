---
title: Repository Protocols in Domain, Implementations in Data Layer
impact: HIGH
impactDescription: O(1) data source swap — change one implementation file vs N view files
tags: layer, repository, protocol, data-layer, dependency-inversion
---

## Repository Protocols in Domain, Implementations in Data Layer

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Repository protocols are defined in the Domain layer — they describe WHAT data operations are available without specifying HOW they're performed. Concrete implementations (networking, CoreData, SwiftData, UserDefaults) live in the Data layer. This inversion means the Domain never depends on the Data layer, data sources can be swapped without touching business logic, and testing uses mock repositories.

**Incorrect (repository class in Domain importing networking — domain depends on data layer):**

```swift
// Domain/Repositories/UserRepository.swift

import Foundation  // URLSession dependency in domain

// Concrete class in Domain — hardcodes networking implementation
class UserRepository {
    private let baseURL = URL(string: "https://api.example.com")!

    // Domain knows HOW data is fetched — violates dependency inversion
    func fetchUser(id: String) async throws -> User {
        let url = baseURL.appendingPathComponent("users/\(id)")
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // Cannot swap to local database without modifying domain code
    func saveUser(_ user: User) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("users"))
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(user)
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
```

**Correct (protocol in Domain, concrete implementations in Data layer — dependency inverted):**

```swift
// Domain/Repositories/UserRepository.swift

// Protocol in Domain — describes WHAT, not HOW
// No imports — pure Swift
protocol UserRepository: Sendable {
    func fetchUser(id: String) async throws -> User
    func fetchAll() async throws -> [User]
    func save(_ user: User) async throws
    func delete(id: String) async throws
}

// Data/Repositories/RemoteUserRepository.swift

import Foundation  // Framework imports only in Data layer

// Concrete implementation in Data layer — Domain doesn't know this exists
final class RemoteUserRepository: UserRepository {
    private let networkClient: NetworkClient
    private let baseURL: URL

    init(networkClient: NetworkClient, baseURL: URL) {
        self.networkClient = networkClient
        self.baseURL = baseURL
    }

    func fetchUser(id: String) async throws -> User {
        try await networkClient.get(
            url: baseURL.appendingPathComponent("users/\(id)")
        )
    }

    func fetchAll() async throws -> [User] {
        try await networkClient.get(
            url: baseURL.appendingPathComponent("users")
        )
    }

    func save(_ user: User) async throws {
        try await networkClient.post(
            url: baseURL.appendingPathComponent("users"),
            body: user
        )
    }

    func delete(id: String) async throws {
        try await networkClient.delete(
            url: baseURL.appendingPathComponent("users/\(id)")
        )
    }
}

// Data/Repositories/SwiftDataUserRepository.swift

import SwiftData  // Persistence framework only in Data layer

final class SwiftDataUserRepository: UserRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchUser(id: String) async throws -> User {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.notFound
        }
        return entity.toDomainModel()
    }

    func fetchAll() async throws -> [User] {
        let descriptor = FetchDescriptor<UserEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomainModel() }
    }

    // ... same interface, different implementation
    func save(_ user: User) async throws { /* SwiftData save */ }
    func delete(id: String) async throws { /* SwiftData delete */ }
}

// Testing — mock repository, no network or database required
final class MockUserRepository: UserRepository {
    var users: [User] = []
    var fetchUserCallCount = 0

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        guard let user = users.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return user
    }

    func fetchAll() async throws -> [User] { users }
    func save(_ user: User) async throws { users.append(user) }
    func delete(id: String) async throws { users.removeAll { $0.id == id } }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
