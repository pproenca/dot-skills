---
title: All Injected Dependencies Are Protocol Types
impact: MEDIUM-HIGH
impactDescription: concrete types prevent mock injection and break test isolation
tags: di, protocol, abstraction, testing, mock
---

## All Injected Dependencies Are Protocol Types

Every dependency injected via `@Environment` or init must be typed as a protocol, never a concrete class. This enables test doubles (mocks, stubs, fakes) to be injected without changing view or ViewModel code. The `EnvironmentKey`'s `defaultValue` can be a live implementation, but the type annotation must always be the protocol. Use `any ProtocolName` for existential types in Swift 5.9+.

**Incorrect (concrete class type — impossible to substitute for testing):**

```swift
// EnvironmentKey typed to concrete class
extension EnvironmentValues {
    @Entry var userService: UserService = UserService()
    //                      ^^^^^^^^^^^ concrete class — locked in
}

@Observable
class ProfileViewModel {
    // Concrete type — cannot inject a mock without subclassing
    let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    func loadProfile() async {
        // Always hits the real network — tests are slow and flaky
        let user = try? await userService.fetchCurrentUser()
    }
}

// Tests MUST use the real UserService or resort to fragile subclass overrides
```

**Correct (protocol type — mocks inject cleanly):**

```swift
// Protocol defines the contract
protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User
    func updateProfile(_ profile: ProfileUpdate) async throws -> User
}

// Live implementation conforms to the protocol
final class UserService: UserServiceProtocol {
    func fetchCurrentUser() async throws -> User {
        // Real network call
    }

    func updateProfile(_ profile: ProfileUpdate) async throws -> User {
        // Real network call
    }
}

// EnvironmentKey typed to protocol — any conforming type can be injected
extension EnvironmentValues {
    @Entry var userService: any UserServiceProtocol = UserService()
    //                      ^^^^^^^^^^^^^^^^^^^^^^^ protocol type
}

@Observable
class ProfileViewModel {
    private let userService: any UserServiceProtocol

    init(userService: any UserServiceProtocol) {
        self.userService = userService
    }

    func loadProfile() async {
        let user = try? await userService.fetchCurrentUser()
    }
}

// In views — protocol type flows through @Environment
struct ProfileView: View {
    @Environment(\.userService) var userService

    var body: some View {
        ProfileContent()
            .task {
                // userService is protocol-typed — mock or live, view doesn't care
            }
    }
}
```

**Key rules:**
- `any ProtocolName` is required in Swift 5.9+ for existential protocol types
- The protocol lives in the Domain layer; the concrete implementation lives in the Data layer
- Views and ViewModels NEVER import or reference the concrete type directly

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
