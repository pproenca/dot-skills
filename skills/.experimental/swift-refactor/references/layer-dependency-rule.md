---
title: Extract Domain Layer with Zero Framework Imports
impact: HIGH
impactDescription: enables 100% domain test coverage without simulator — 10× faster test execution
tags: layer, dependency-rule, domain, clean-architecture, imports
---

## Extract Domain Layer with Zero Framework Imports

Business logic scattered across views and services that import SwiftUI, CoreData, or networking frameworks cannot be tested without a simulator. Extract a Domain layer containing models, repository/coordinator/error protocols with zero framework imports. `import Foundation` is acceptable for standard types (`Date`, `URL`, `UUID`, `Decimal`) but NEVER for networking or persistence.

**Incorrect (domain logic coupled to frameworks — requires simulator to test):**

```swift
import SwiftUI
import SwiftData

class FetchUserProfileUseCase {
    func execute(userId: String) async throws -> UserProfile {
        let url = URL(string: "https://api.example.com/users/\(userId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
}

@Model
class UserProfile {
    var id: String
    var name: String
    @Attribute(.spotlight) var bio: String
    var displayColor: Color { isPremium ? .gold : .primary }
}
```

**Correct (pure Swift domain — zero framework imports, testable anywhere):**

```swift
// Domain/UseCases/FetchUserProfileUseCase.swift
// No framework imports — pure Swift

protocol FetchUserProfileUseCase {
    func execute(userId: String) async throws -> UserProfile
}

final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(userId: String) async throws -> UserProfile {
        let user = try await userRepository.fetchUser(id: userId)
        return UserProfile(
            id: user.id,
            name: user.name,
            bio: user.bio,
            membershipTier: MembershipTier(from: user.joinDate)
        )
    }
}

// Domain/Models/UserProfile.swift
struct UserProfile: Equatable, Sendable {
    let id: String
    let name: String
    let bio: String
    let membershipTier: MembershipTier
}

// Domain/Repositories/UserRepository.swift
protocol UserRepository: Sendable {
    func fetchUser(id: String) async throws -> User
}
```

**Dependency rule:** Views -> Domain <- Data. Domain has zero framework imports.

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
