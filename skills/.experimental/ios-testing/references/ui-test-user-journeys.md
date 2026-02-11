---
title: "Test Complete User Journeys, Not Individual Screens"
impact: MEDIUM
impactDescription: "prevents 30%+ of integration bugs that unit tests miss"
tags: ui, user-journey, acceptance, end-to-end, integration
---

## Test Complete User Journeys, Not Individual Screens

Testing screens in isolation verifies that elements exist but misses broken transitions, lost state between screens, and incorrect deep-link handling. Journey tests exercise the same paths real users take, catching integration failures before they ship.

**Incorrect (isolated screen checks that miss flow bugs):**

```swift
func testProductDetailScreenShowsAddButton() {
    let app = XCUIApplication()
    app.launchArguments += ["--uitesting", "--mock-catalog"]
    app.launch()

    // Navigates directly — never validates the transition from browse → detail
    app.tables.cells["productCell_0"].tap()

    XCTAssertTrue(app.buttons["addToCartButton"].exists)
}

func testCartScreenShowsCheckoutButton() {
    let app = XCUIApplication()
    app.launchArguments += ["--uitesting", "--mock-cart-with-item"]
    app.launch()

    // Skips adding an item — never validates the add-to-cart integration
    app.tabBars.buttons["Cart"].tap()

    XCTAssertTrue(app.buttons["checkoutButton"].exists)
}
```

**Correct (end-to-end journey validates transitions and state):**

```swift
func testBrowseToCheckoutJourney() {
    let app = XCUIApplication()
    app.launchArguments += ["--uitesting", "--mock-catalog"]
    app.launch()

    // Browse → Detail
    app.tables.cells["productCell_0"].tap()
    XCTAssertTrue(app.buttons["addToCartButton"].waitForExistence(timeout: 5))

    // Detail → Cart (validates item actually persists across screens)
    app.buttons["addToCartButton"].tap()
    app.tabBars.buttons["Cart"].tap()
    XCTAssertTrue(app.cells["cartItemCell_0"].waitForExistence(timeout: 5))

    // Cart → Checkout
    app.buttons["checkoutButton"].tap()
    XCTAssertTrue(app.staticTexts["orderSummaryTitle"].waitForExistence(timeout: 5))
}
```
