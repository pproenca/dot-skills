---
title: "One Assertion Concept Per Test"
impact: MEDIUM-HIGH
impactDescription: "reduces failure investigation time by 3-5×"
tags: arch, single-responsibility, test-naming, readability
---

## One Assertion Concept Per Test

When a test asserts multiple unrelated behaviors, the first failure masks all subsequent checks. Splitting each concept into its own test method produces a failure list that immediately tells you which behaviors broke and which still work.

**Incorrect (first failure hides 4 other potential problems):**

```swift
final class UserRegistrationTests: XCTestCase {
    func testRegistration() async throws {
        let service = RegistrationService(validator: MockValidator(), store: MockUserStore())

        let result = try await service.register(email: "jo@example.com", password: "Str0ng!Pass")

        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(result.user?.email, "jo@example.com")
        XCTAssertNotNil(result.user?.id)
        XCTAssertTrue(result.user?.isEmailVerified == false) // if line 2 fails, you never know about lines 3-5
        XCTAssertEqual(result.welcomeEmailQueued, true)
    }
}
```

**Correct (each failure names the exact broken behavior):**

```swift
final class UserRegistrationTests: XCTestCase {
    private var service: RegistrationService!

    override func setUp() {
        service = RegistrationService(validator: MockValidator(), store: MockUserStore())
    }

    func testRegistrationSucceeds() async throws {
        let result = try await service.register(email: "jo@example.com", password: "Str0ng!Pass")
        XCTAssertTrue(result.isSuccess)
    }

    func testRegistrationAssignsUniqueId() async throws {
        let result = try await service.register(email: "jo@example.com", password: "Str0ng!Pass")
        XCTAssertNotNil(result.user?.id) // one concept — ID assignment
    }

    func testRegistrationQueuesWelcomeEmail() async throws {
        let result = try await service.register(email: "jo@example.com", password: "Str0ng!Pass")
        XCTAssertTrue(result.welcomeEmailQueued)
    }
}
```
