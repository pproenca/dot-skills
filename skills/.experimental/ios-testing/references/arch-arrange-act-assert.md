---
title: "Structure Tests as Arrange-Act-Assert"
impact: MEDIUM-HIGH
impactDescription: "reduces debugging time by 50%+"
tags: arch, arrange-act-assert, readability, structure
---

## Structure Tests as Arrange-Act-Assert

When setup, execution, and verification are interleaved, readers must mentally untangle what the test does before they can diagnose a failure. Separating each test into Arrange, Act, and Assert sections makes the intent scannable at a glance and cuts debugging time in half.

**Incorrect (interleaved phases obscure what is being tested):**

```swift
final class ShoppingCartTests: XCTestCase {
    func testApplyDiscount() {
        let cart = ShoppingCart()
        cart.add(Item(name: "Keyboard", price: 80.00))
        XCTAssertEqual(cart.total, 80.00)
        cart.add(Item(name: "Mouse", price: 40.00))
        XCTAssertEqual(cart.itemCount, 2) // assertion mixed into setup
        cart.applyDiscount(code: "SAVE20")
        XCTAssertEqual(cart.total, 96.00)
        XCTAssertTrue(cart.hasActiveDiscount) // unclear which action this validates
    }
}
```

**Correct (three distinct phases, scannable in seconds):**

```swift
final class ShoppingCartTests: XCTestCase {
    func testApplyDiscountReducesTotal() {
        // Arrange
        let cart = ShoppingCart()
        cart.add(Item(name: "Keyboard", price: 80.00))
        cart.add(Item(name: "Mouse", price: 40.00))

        // Act
        cart.applyDiscount(code: "SAVE20")

        // Assert
        XCTAssertEqual(cart.total, 96.00) // 20% off 120.00
    }
}
```
