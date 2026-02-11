---
title: "Configure Test State via Launch Arguments"
impact: MEDIUM
impactDescription: "eliminates manual test data setup and network dependency"
tags: ui, launch-arguments, configuration, deterministic, xcuitest
---

## Configure Test State via Launch Arguments

UI tests that depend on real API responses or pre-existing server state are slow, flaky, and impossible to run offline. Passing launch arguments lets the app switch to mock data at startup, making tests deterministic and self-contained.

**Incorrect (depends on real API and existing server data):**

```swift
func testOrderHistoryDisplaysRecentOrders() {
    let app = XCUIApplication()
    app.launch()

    // Relies on real API — fails if server is down, data changes, or network is slow
    let loginPage = LoginPage(app: app)
    loginPage.login(email: "test@example.com", password: "livePassword")

    app.tabBars.buttons["Orders"].tap()

    XCTAssertTrue(app.cells["orderCell_0"].waitForExistence(timeout: 10))
}
```

**Correct (deterministic with mock data flags):**

```swift
func testOrderHistoryDisplaysRecentOrders() {
    let app = XCUIApplication()
    // App checks these flags at startup and loads stub responses instead of calling the network
    app.launchArguments += ["--uitesting", "--mock-orders"]
    app.launch()

    let loginPage = LoginPage(app: app)
    loginPage.login(email: "test@example.com", password: "livePassword")

    app.tabBars.buttons["Orders"].tap()

    // Passes offline, in CI, and regardless of server state
    XCTAssertTrue(app.cells["orderCell_0"].waitForExistence(timeout: 5))
}
```
