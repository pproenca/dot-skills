---
title: "Use #expect and #require Over XCTAssert"
impact: HIGH
impactDescription: "3-5× more diagnostic detail per assertion failure"
tags: unit, expect, require, swift-testing, diagnostics
---

## Use #expect and #require Over XCTAssert

XCTAssert functions produce generic failure messages like "XCTAssertEqual failed: (3) is not equal to (5)" with no context about what the values represent. #expect captures the entire expression tree at the macro level, showing property names, intermediate values, and the exact subexpression that diverged, cutting average diagnosis time from minutes to seconds.

**Incorrect (failure output hides what the values represent):**

```swift
func testAppliesLoyaltyDiscount() {
    let pricing = PricingEngine(loyaltyTier: .gold)
    let quote = pricing.calculateQuote(for: cartItems)

    XCTAssertEqual(quote.discount, 0.15) // failure: "XCTAssertEqual failed: (0.10) is not equal to (0.15)" — which discount? why 0.10?
    XCTAssertTrue(quote.lineItems.allSatisfy { $0.discountApplied }) // failure: "XCTAssertTrue failed" — no detail on which item failed
    XCTAssertGreaterThan(quote.total, 0)
}
```

**Correct (failure output shows the full expression with values):**

```swift
@Test func appliesLoyaltyDiscount() {
    let pricing = PricingEngine(loyaltyTier: .gold)
    let quote = pricing.calculateQuote(for: cartItems)

    #expect(quote.discount == 0.15) // failure: "Expectation failed: (quote.discount → 0.10) == 0.15"
    #expect(quote.lineItems.allSatisfy { $0.discountApplied }) // failure shows which lineItem has discountApplied == false
    #expect(quote.total > 0)
}
```
