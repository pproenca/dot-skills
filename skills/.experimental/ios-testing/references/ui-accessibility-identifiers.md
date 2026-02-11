---
title: "Use Accessibility Identifiers for Element Queries"
impact: MEDIUM
impactDescription: "eliminates test breakage from text/localization changes"
tags: ui, accessibility-identifiers, xcuitest, stability, localization
---

## Use Accessibility Identifiers for Element Queries

Querying elements by visible text couples tests to copy and localization strings. Any label change or translation update breaks every test that references it, even though the UI behavior is unchanged.

**Incorrect (breaks when button text or locale changes):**

```swift
func testAddToCartButton() {
    let app = XCUIApplication()
    app.launch()

    // Breaks if text changes to "Add to Bag" or app runs in Spanish
    let addButton = app.buttons["Add to Cart"]
    addButton.tap()

    let confirmationLabel = app.staticTexts["Item added successfully"]
    XCTAssertTrue(confirmationLabel.exists)
}
```

**Correct (stable across text and localization changes):**

```swift
func testAddToCartButton() {
    let app = XCUIApplication()
    app.launch()

    // Survives copy changes and localization — identifier is developer-controlled
    let addButton = app.buttons["addToCartButton"]
    addButton.tap()

    let confirmationLabel = app.staticTexts["cartConfirmationLabel"]
    XCTAssertTrue(confirmationLabel.exists)
}
```
