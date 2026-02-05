---
title: Write Tests with Swift Testing Framework
impact: MEDIUM
impactDescription: catches logic bugs before they reach users, #expect macro provides clear failure messages
tags: test, swift-testing, expect, unit-test, model
---

## Write Tests with Swift Testing Framework

Shipping model logic without tests means bugs reach users first. The Swift Testing framework uses `@Test` functions and the `#expect` macro to verify behavior with clear, readable failure messages that pinpoint exactly what went wrong.

**Incorrect (model logic shipped without any tests):**

```swift
struct ShoppingCart {
    private(set) var items: [CartItem] = []

    mutating func add(_ product: Product, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    var totalPrice: Decimal {
        items.reduce(0) { $0 + $1.product.price * Decimal($1.quantity) }
    }
}
// No tests written for add() or totalPrice
```

**Correct (test verifies model behavior with #expect):**

```swift
import Testing

@Test func addingProductToCartIncreasesTotal() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 2)

    #expect(cart.items.count == 1)
    #expect(cart.totalPrice == 25.98) // 12.99 * 2
}

@Test func addingSameProductMergesQuantity() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 1)
    cart.add(coffee, quantity: 3)

    #expect(cart.items.count == 1) // merged, not duplicated
    #expect(cart.items[0].quantity == 4)
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
