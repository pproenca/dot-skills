---
title: Every Protocol Dependency Has a Mock for Testing
impact: MEDIUM
impactDescription: 100× faster tests — milliseconds vs seconds for network-dependent test suites
tags: di, mock, testing, protocol, test-double
---

## Every Protocol Dependency Has a Mock for Testing

For every protocol dependency in the app, provide a Mock implementation in the test target. Mocks should record method calls (for verification), return configurable responses, and optionally throw errors (for error path testing). This enables fast, isolated, deterministic unit tests for ViewModels and UseCases.

**Incorrect (unit test using real service — slow, flaky, non-deterministic):**

```swift
// Test that hits the real API — slow, requires network, results vary
final class ProfileViewModelTests: XCTestCase {
    func testLoadProfile() async {
        // Real service — makes actual HTTP requests
        let realService = UserService(baseURL: "https://api.example.com")
        let viewModel = ProfileViewModel(userService: realService)

        await viewModel.loadProfile()

        // Flaky: depends on network, API availability, test data state
        XCTAssertNotNil(viewModel.user)
        // Can't test error paths without breaking the real server
        // Can't verify which methods were called
        // Takes 200ms+ per test instead of <1ms
    }
}
```

**Correct (mock with call recording and configurable responses):**

```swift
// Mock in test target — records calls and returns configured responses
final class MockUserService: UserServiceProtocol {
    // Call recording — verify what was called and with what arguments
    var fetchCurrentUserCallCount = 0
    var updateProfileCallCount = 0
    var updateProfileLastArgument: ProfileUpdate?

    // Configurable responses — control what the mock returns
    var fetchCurrentUserResult: Result<User, Error> = .success(
        User(id: "1", name: "Test User", email: "test@example.com")
    )
    var updateProfileResult: Result<User, Error> = .success(
        User(id: "1", name: "Updated", email: "test@example.com")
    )

    func fetchCurrentUser() async throws -> User {
        fetchCurrentUserCallCount += 1
        return try fetchCurrentUserResult.get()
    }

    func updateProfile(_ profile: ProfileUpdate) async throws -> User {
        updateProfileCallCount += 1
        updateProfileLastArgument = profile
        return try updateProfileResult.get()
    }
}

// Tests are fast, isolated, and deterministic
final class ProfileViewModelTests: XCTestCase {
    private var mockService: MockUserService!
    private var viewModel: ProfileViewModel!

    override func setUp() {
        mockService = MockUserService()
        viewModel = ProfileViewModel(userService: mockService)
    }

    func testLoadProfileSuccess() async {
        let expectedUser = User(id: "42", name: "Alice", email: "alice@test.com")
        mockService.fetchCurrentUserResult = .success(expectedUser)

        await viewModel.loadProfile()

        XCTAssertEqual(mockService.fetchCurrentUserCallCount, 1)
        XCTAssertEqual(viewModel.user?.name, "Alice")
        XCTAssertEqual(viewModel.state, .loaded)
    }

    func testLoadProfileError() async {
        // Configure mock to throw — tests error path without a real server
        mockService.fetchCurrentUserResult = .failure(URLError(.notConnectedToInternet))

        await viewModel.loadProfile()

        XCTAssertEqual(mockService.fetchCurrentUserCallCount, 1)
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.state, .error)
    }

    func testUpdateProfilePassesCorrectArgument() async throws {
        let update = ProfileUpdate(name: "New Name", bio: "New bio")

        try await viewModel.updateProfile(update)

        XCTAssertEqual(mockService.updateProfileCallCount, 1)
        XCTAssertEqual(mockService.updateProfileLastArgument?.name, "New Name")
    }
}
```

**Mock pattern checklist:**
- Call count tracking for each method (verify calls were made)
- Argument capture for methods with parameters (verify correct data passed)
- Configurable `Result<Success, Error>` for each method (control success/failure)
- Default success values so tests only configure what they're testing

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
