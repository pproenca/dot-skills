---
title: "Use Swift Testing Over XCTest for New Tests"
impact: CRITICAL
impactDescription: "3-5x more expressive assertions with #expect"
tags: unit, swift-testing, expect, test-attribute
---

## Use Swift Testing Over XCTest for New Tests

XCTest requires class inheritance, setUp/tearDown lifecycle methods, and verbose assertion functions that obscure test intent. Swift Testing replaces this ceremony with lightweight structs, @Test attributes, and #expect macros that read like plain-language specifications and produce richer failure diagnostics.

**Incorrect (boilerplate obscures the actual test logic):**

```swift
import XCTest
@testable import Payments

final class PaymentValidatorTests: XCTestCase { // class inheritance required
    var validator: PaymentValidator!

    override func setUp() { // lifecycle method for simple init
        super.setUp()
        validator = PaymentValidator()
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    func testValidatesMinimumAmount() {
        let result = validator.validate(amount: 0.50, currency: .usd)
        XCTAssertFalse(result.isValid) // failure message: "XCTAssertFalse failed"
        XCTAssertEqual(result.error, .belowMinimum)
    }
}
```

**Correct (zero boilerplate, intent-revealing structure):**

```swift
import Testing
@testable import Payments

@Suite struct PaymentValidatorTests {
    let validator = PaymentValidator() // init replaces setUp, no tearDown needed

    @Test func validatesMinimumAmount() {
        let result = validator.validate(amount: 0.50, currency: .usd)
        #expect(!result.isValid) // failure shows: "Expectation failed: !(PaymentResult(isValid: false, …).isValid)"
        #expect(result.error == .belowMinimum)
    }
}
```
