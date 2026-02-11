---
title: "Name Tests After the Behavior They Verify"
impact: HIGH
impactDescription: "eliminates investigation time when tests fail"
tags: unit, naming, readability, diagnostics
---

## Name Tests After the Behavior They Verify

Vague test names like `testLogin()` force developers to read the test body to understand what broke. A name that states the scenario and expected outcome turns every failure into an instant diagnosis, saving 2-5 minutes of investigation per red test in CI.

**Incorrect (name describes the feature, not the behavior):**

```swift
@Suite struct AuthServiceTests {
    @Test func testLogin() { // which login scenario? what should happen?
        let service = AuthService(client: MockClient(returning: .expiredToken))
        let result = service.login(email: "user@example.com", password: "valid-password")
        #expect(result == .failure(.tokenExpired))
    }

    @Test func testLogin2() { // numbered variants are unreadable in CI output
        let service = AuthService(client: MockClient(returning: .success))
        let result = service.login(email: "", password: "valid-password")
        #expect(result == .failure(.invalidEmail))
    }
}
```

**Correct (failure message tells you exactly what broke):**

```swift
@Suite struct AuthServiceTests {
    @Test("Login with expired token returns authentication error")
    func loginWithExpiredToken_returnsAuthenticationError() { // display name for CI, method name for code navigation
        let service = AuthService(client: MockClient(returning: .expiredToken))
        let result = service.login(email: "user@example.com", password: "valid-password")
        #expect(result == .failure(.tokenExpired))
    }

    @Test("Login with empty email returns validation error")
    func loginWithEmptyEmail_returnsValidationError() {
        let service = AuthService(client: MockClient(returning: .success))
        let result = service.login(email: "", password: "valid-password")
        #expect(result == .failure(.invalidEmail))
    }
}
```
