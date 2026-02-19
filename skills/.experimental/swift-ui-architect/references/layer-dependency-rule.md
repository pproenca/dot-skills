---
title: Domain Layer Has Zero Framework Imports
impact: HIGH
impactDescription: enables 100% domain test coverage without simulator — 10× faster test execution
tags: layer, dependency-rule, domain, clean-architecture, imports
---

## Domain Layer Has Zero Framework Imports

The Domain layer contains domain models, repository/coordinator protocols, and error types. It MUST NOT import SwiftUI, UIKit, CoreData, SwiftData, or any third-party framework. `import Foundation` is acceptable for standard types (`Date`, `URL`, `UUID`, `Decimal`, `Data`, `Codable`) but NEVER for networking (`URLSession`) or persistence. This ensures domain logic is testable without simulators, portable across platforms, and independent of Apple's framework changes.

**Incorrect (domain layer importing frameworks — coupled, non-portable, requires simulator to test):**

```swift
// Domain/UseCases/FetchUserProfileUseCase.swift

import SwiftUI      // Framework import in domain — violates dependency rule
import Foundation   // URLSession dependency leaks into domain
import SwiftData    // Persistence framework in domain — non-portable

class FetchUserProfileUseCase {
    // Direct framework dependency — requires network to test
    func execute(userId: String) async throws -> UserProfile {
        let url = URL(string: "https://api.example.com/users/\(userId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
        return profile
    }
}

// Domain model coupled to SwiftData — requires framework to compile
@Model
class UserProfile {
    var id: String
    var name: String
    @Attribute(.spotlight) var bio: String  // SwiftData attribute in domain
    @Relationship var orders: [Order]       // SwiftData relationship in domain

    // SwiftUI dependency in domain model
    var displayColor: Color {
        isPremium ? .gold : .primary
    }
}
```

**Correct (pure Swift domain — zero framework imports, testable anywhere):**

```swift
// Domain/UseCases/FetchUserProfileUseCase.swift

// No imports — pure Swift only
// Compiles and tests without Xcode, simulators, or Apple frameworks

protocol FetchUserProfileUseCase {
    func execute(userId: String) async throws -> UserProfile
}

final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // Business logic only — no networking, no persistence, no UI
    func execute(userId: String) async throws -> UserProfile {
        let user = try await userRepository.fetchUser(id: userId)

        // Domain logic: enrich profile with computed business rules
        return UserProfile(
            id: user.id,
            name: user.name,
            bio: user.bio,
            membershipTier: MembershipTier(from: user.joinDate),
            canAccessPremiumContent: user.subscription.isActive
        )
    }
}

// Domain/Models/UserProfile.swift

// Pure Swift struct — no framework annotations
struct UserProfile: Equatable, Sendable {
    let id: String
    let name: String
    let bio: String
    let membershipTier: MembershipTier
    let canAccessPremiumContent: Bool
}

// Domain/Repositories/UserRepository.swift

// Protocol in domain — implementation in Data layer
protocol UserRepository: Sendable {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
