---
title: "Separate Unit and UI Test Targets"
impact: HIGH
impactDescription: "3-10× faster unit test feedback loop"
tags: arch, test-targets, organization, xcode
---

## Separate Unit and UI Test Targets

Mixing UI tests into the unit test target forces the entire test suite to launch the simulator and boot the app for every run. Separating targets lets unit tests execute in-process in under a second while UI tests run independently on CI.

**Incorrect (unit tests wait for app launch on every run):**

```swift
// MyAppTests target (single target for everything)
import XCTest
@testable import MyApp

// This runs fast but is trapped in a UI test target
final class PriceFormatterTests: XCTestCase {
    func testFormatsWithCurrency() {
        let result = PriceFormatter.format(amount: 29.99, currency: .gbp)
        XCTAssertEqual(result, "£29.99")
    }
}

// This forces the entire target to launch the app
final class CheckoutFlowUITests: XCTestCase { // UI test mixed into unit target — 8s launch penalty on every run
    func testCompletePurchase() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add to Cart"].tap()
        app.buttons["Checkout"].tap()
        XCTAssertTrue(app.staticTexts["Order Confirmed"].exists)
    }
}
```

**Correct (unit tests run in milliseconds, UI tests run separately):**

```swift
// MyAppUnitTests target — no host app, no simulator boot
import XCTest
@testable import MyApp

final class PriceFormatterTests: XCTestCase {
    func testFormatsWithCurrency() {
        let result = PriceFormatter.format(amount: 29.99, currency: .gbp)
        XCTAssertEqual(result, "£29.99")
    }
}

// MyAppUITests target — separate target, runs only when explicitly selected
import XCTest

final class CheckoutFlowUITests: XCTestCase { // isolated target — unit tests unaffected
    func testCompletePurchase() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add to Cart"].tap()
        app.buttons["Checkout"].tap()
        XCTAssertTrue(app.staticTexts["Order Confirmed"].exists)
    }
}
```
