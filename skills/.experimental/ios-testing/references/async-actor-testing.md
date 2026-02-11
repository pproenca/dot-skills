---
title: "Test Actor State Through Async Interface"
impact: MEDIUM-HIGH
impactDescription: "prevents data races in actor tests"
tags: async, actors, concurrency, data-races
---

## Test Actor State Through Async Interface

Actor properties are isolated and cannot be accessed synchronously from outside the actor. Attempting to read actor state directly results in a compiler error, and using `nonisolated` workarounds defeats the actor's data-race protection. Always access actor state through its async interface, exactly as production code does.

**Incorrect (bypasses actor isolation to read state):**

```swift
actor ShoppingCart {
    private(set) var items: [CartItem] = []

    func add(_ item: CartItem) {
        items.append(item)
    }

    nonisolated var itemSnapshot: [CartItem] { // breaks isolation — data race under concurrent access
        []
    }
}

final class ShoppingCartTests: XCTestCase {
    func testAddItem() {
        let cart = ShoppingCart()
        let item = CartItem(sku: "SHOE-001", quantity: 1)

        Task { await cart.add(item) }

        XCTAssertEqual(cart.itemSnapshot.count, 1) // race condition — task may not have completed
    }
}
```

**Correct (awaits actor's async interface):**

```swift
actor ShoppingCart {
    private(set) var items: [CartItem] = []

    func add(_ item: CartItem) {
        items.append(item)
    }

    var itemCount: Int { items.count } // actor-isolated property — safe to await
}

final class ShoppingCartTests: XCTestCase {
    func testAddItem() async {
        let cart = ShoppingCart()
        let item = CartItem(sku: "SHOE-001", quantity: 1)

        await cart.add(item)

        let count = await cart.itemCount // awaits actor hop — no data race
        XCTAssertEqual(count, 1)
    }
}
```
