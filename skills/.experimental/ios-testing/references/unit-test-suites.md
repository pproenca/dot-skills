---
title: "Organize Related Tests Into Suites"
impact: MEDIUM
impactDescription: "enables selective execution and shared setup"
tags: unit, suite, organization, swift-testing, setup
---

## Organize Related Tests Into Suites

Flat test files with dozens of unrelated functions make it hard to run a subset and force duplicate setup code. @Suite structs group related tests under a named scope with shared initialization through init(), and nested suites create a hierarchy that mirrors the feature structure of the production code.

**Incorrect (flat functions with repeated setup in every test):**

```swift
@Test func createsCartWithSingleItem() {
    let catalog = StubCatalog()
    let cart = ShoppingCart(catalog: catalog) // duplicated in every test
    cart.add(itemId: "sku-100", quantity: 1)
    #expect(cart.items.count == 1)
}

@Test func calculatesCartSubtotal() {
    let catalog = StubCatalog()
    let cart = ShoppingCart(catalog: catalog) // same setup, no way to run cart tests together
    cart.add(itemId: "sku-100", quantity: 2)
    #expect(cart.subtotal == 39.98)
}

@Test func appliesFreeShippingThreshold() {
    let catalog = StubCatalog()
    let cart = ShoppingCart(catalog: catalog)
    cart.add(itemId: "sku-200", quantity: 3)
    #expect(cart.shippingCost == 0)
}
```

**Correct (suite groups tests with shared setup via init):**

```swift
@Suite("Shopping Cart")
struct ShoppingCartTests {
    let cart: ShoppingCart // ShoppingCart is a final class — init() creates a fresh instance per test

    init() { // Swift Testing calls init() before each @Test — replaces setUp without inheritance
        let catalog = StubCatalog()
        cart = ShoppingCart(catalog: catalog)
    }

    @Test func createsCartWithSingleItem() {
        cart.add(itemId: "sku-100", quantity: 1)
        #expect(cart.items.count == 1)
    }

    @Test func calculatesSubtotal() {
        cart.add(itemId: "sku-100", quantity: 2)
        #expect(cart.subtotal == 39.98)
    }

    @Test func appliesFreeShippingThreshold() {
        cart.add(itemId: "sku-200", quantity: 3)
        #expect(cart.shippingCost == 0)
    }
}
```
