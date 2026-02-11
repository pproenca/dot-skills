---
title: "Wait for Elements Instead of Using sleep()"
impact: MEDIUM
impactDescription: "reduces UI test flakiness by 80%+ and speeds up execution"
tags: ui, wait, existence, flakiness, performance
---

## Wait for Elements Instead of Using sleep()

Fixed-duration sleeps either wait too long (slowing the suite) or not long enough (causing flaky failures). Element-based waits resolve the instant the condition is met and fail with a clear timeout, making tests both faster and more reliable.

**Incorrect (arbitrary delay that is too short on CI, too long locally):**

```swift
func testSearchResultsAppear() {
    let app = XCUIApplication()
    app.launch()

    app.searchFields["searchField"].tap()
    app.searchFields["searchField"].typeText("running shoes")
    app.buttons["searchButton"].tap()

    // 3 seconds may not be enough on CI; wastes time when results load in 500ms
    Thread.sleep(forTimeInterval: 3)

    XCTAssertTrue(app.cells["productCell_0"].exists)
}
```

**Correct (resolves as soon as element appears, fails clearly on timeout):**

```swift
func testSearchResultsAppear() {
    let app = XCUIApplication()
    app.launch()

    app.searchFields["searchField"].tap()
    app.searchFields["searchField"].typeText("running shoes")
    app.buttons["searchButton"].tap()

    // Returns immediately when element appears; fails with descriptive timeout error
    let firstResult = app.cells["productCell_0"]
    XCTAssertTrue(firstResult.waitForExistence(timeout: 10))
}
```
