---
title: "Test MainActor-Isolated Code on MainActor"
impact: HIGH
impactDescription: "prevents runtime crashes from wrong-actor access"
tags: async, main-actor, isolation, concurrency, safety
---

## Test MainActor-Isolated Code on MainActor

Calling a `@MainActor`-isolated method from a non-isolated test context triggers a runtime assertion or data race. Annotating the test function with `@MainActor` ensures the test body executes on the main actor, matching the isolation context of the code under test.

**Incorrect (test runs off the main actor — runtime crash):**

```swift
final class ProfileViewModelTests: XCTestCase {
    func testLoadProfileUpdatesDisplayName() async throws {
        let viewModel = ProfileViewModel(fetcher: MockProfileFetcher())

        await viewModel.loadProfile(userId: "usr_42") // @MainActor method called from nonisolated context — potential crash
        XCTAssertEqual(viewModel.displayName, "Ada Lovelace")
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var displayName: String = ""
    private let fetcher: ProfileFetching

    init(fetcher: ProfileFetching) { self.fetcher = fetcher }

    func loadProfile(userId: String) async {
        let user = try? await fetcher.fetchProfile(userId: userId)
        displayName = user?.fullName ?? "Unknown"
    }
}
```

**Correct (test shares the same actor isolation):**

```swift
final class ProfileViewModelTests: XCTestCase {
    @MainActor
    func testLoadProfileUpdatesDisplayName() async throws {
        let viewModel = ProfileViewModel(fetcher: MockProfileFetcher())

        await viewModel.loadProfile(userId: "usr_42") // same isolation context — safe access guaranteed
        XCTAssertEqual(viewModel.displayName, "Ada Lovelace")
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var displayName: String = ""
    private let fetcher: ProfileFetching

    init(fetcher: ProfileFetching) { self.fetcher = fetcher }

    func loadProfile(userId: String) async {
        let user = try? await fetcher.fetchProfile(userId: userId)
        displayName = user?.fullName ?? "Unknown"
    }
}
```
