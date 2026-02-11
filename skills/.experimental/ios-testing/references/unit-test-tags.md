---
title: "Use Tags to Categorize Cross-Cutting Tests"
impact: MEDIUM
impactDescription: "reduces CI run time by 50%+ for targeted test runs"
tags: unit, tags, swift-testing, filtering, ci
---

## Use Tags to Categorize Cross-Cutting Tests

Splitting tests into separate targets for smoke, regression, and performance creates build-configuration overhead and forces each test into exactly one category. Swift Testing tags let any test belong to multiple categories and run filtered subsets from the command line or CI without extra targets.

**Incorrect (separate targets that duplicate build settings and slow CI):**

```swift
// SmokeTests target — separate scheme, separate build config
final class SmokeLoginTests: XCTestCase {
    func testLoginScreenLoads() {
        let vm = LoginViewModel(auth: MockAuth())
        XCTAssertNotNil(vm) // duplicated build settings just to run this subset
    }
}

// RegressionTests target — another scheme to maintain
final class RegressionLoginTests: XCTestCase {
    func testLoginHandlesUnicodeEmail() {
        let vm = LoginViewModel(auth: MockAuth())
        let result = vm.login(email: "user@example.co.jp", password: "pass")
        XCTAssertEqual(result, .success)
    }
}
```

**Correct (tags on tests, filter by tag in CI):**

```swift
extension Tag {
    @Tag static var smoke: Self
    @Tag static var regression: Self
}

@Suite struct LoginViewModelTests {
    let viewModel = LoginViewModel(auth: MockAuth())

    @Test(.tags(.smoke))
    func screenLoads() {
        #expect(viewModel != nil)
    }

    @Test(.tags(.regression, .smoke)) // one test can belong to multiple categories
    func handlesUnicodeEmail() {
        let result = viewModel.login(email: "user@example.co.jp", password: "pass")
        #expect(result == .success)
    }
}
// CI: swift test --filter .smoke — no extra targets needed
```
