---
title: "Depend on Protocols, Not Concrete Types"
impact: CRITICAL
impactDescription: "enables isolated unit testing of every component"
tags: arch, dependency-injection, protocols, testability
---

## Depend on Protocols, Not Concrete Types

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Concrete dependencies make it impossible to substitute test doubles, forcing tests to hit real networks, databases, and services. Protocol-based dependencies let each component be tested in complete isolation with deterministic behavior.

**Incorrect (every test hits the real network):**

```swift
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    func loadProfile(userId: String) async {
        let url = URL(string: "https://api.example.com/users/\(userId)")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url) // untestable — real HTTP call every run
            user = try JSONDecoder().decode(User.self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**Correct (swap in a mock for sub-millisecond tests):**

```swift
protocol ProfileFetching {
    func fetchProfile(userId: String) async throws -> User
}

final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    private let profileFetcher: ProfileFetching // depends on protocol, not URLSession

    init(profileFetcher: ProfileFetching) {
        self.profileFetcher = profileFetcher
    }

    func loadProfile(userId: String) async {
        do {
            user = try await profileFetcher.fetchProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```
