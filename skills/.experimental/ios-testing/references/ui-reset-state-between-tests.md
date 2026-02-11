---
title: "Reset App State Between UI Tests"
impact: MEDIUM
impactDescription: "prevents cascading failures from shared state"
tags: ui, state-reset, isolation, launch-arguments, independence
---

## Reset App State Between UI Tests

When tests share persisted state — UserDefaults, Keychain tokens, Core Data — a failure in one test corrupts the environment for every subsequent test. Resetting state on each launch ensures every test starts from a known baseline and failures stay isolated.

**Incorrect (tests depend on state left by previous tests):**

```swift
func testLoginSavesSession() {
    let app = XCUIApplication()
    app.launch()

    let loginPage = LoginPage(app: app)
    loginPage.login(email: "user@example.com", password: "securePass1")

    // Saves session to UserDefaults — next test inherits this logged-in state
    XCTAssertTrue(app.staticTexts["dashboardTitle"].waitForExistence(timeout: 5))
}

func testProfileScreenShowsUserEmail() {
    let app = XCUIApplication()
    app.launch()

    // Assumes previous test logged in successfully — fails if run alone or in different order
    app.tabBars.buttons["Profile"].tap()

    XCTAssertTrue(app.staticTexts["user@example.com"].waitForExistence(timeout: 5))
}
```

**Correct (each test resets state and sets up its own preconditions):**

```swift
func testLoginSavesSession() {
    let app = XCUIApplication()
    app.launchArguments += ["--uitesting", "--reset-state"]
    app.launch()

    let loginPage = LoginPage(app: app)
    loginPage.login(email: "user@example.com", password: "securePass1")

    XCTAssertTrue(app.staticTexts["dashboardTitle"].waitForExistence(timeout: 5))
}

func testProfileScreenShowsUserEmail() {
    let app = XCUIApplication()
    // Resets state then pre-seeds a session — runs correctly in any order or in isolation
    app.launchArguments += ["--uitesting", "--reset-state", "--mock-logged-in-user"]
    app.launch()

    app.tabBars.buttons["Profile"].tap()

    XCTAssertTrue(app.staticTexts["user@example.com"].waitForExistence(timeout: 5))
}
```
