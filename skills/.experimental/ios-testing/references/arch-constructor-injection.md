---
title: "Use Constructor Injection Over Service Locators"
impact: CRITICAL
impactDescription: "prevents runtime crashes from missing dependencies"
tags: arch, dependency-injection, constructor, compile-time-safety
---

## Use Constructor Injection Over Service Locators

Service locators and singletons hide dependencies, making it impossible to know what a class needs without reading its implementation. Constructor injection surfaces every dependency at the call site, letting the compiler catch missing or misconfigured dependencies before tests even run.

**Incorrect (hidden dependency discovered only at runtime):**

```swift
final class OrderService {
    func placeOrder(_ order: Order) async throws -> Confirmation {
        let paymentGateway = ServiceLocator.shared.resolve(PaymentGateway.self) // hidden — crashes if not registered
        let inventory = ServiceLocator.shared.resolve(InventoryChecker.self)

        guard try await inventory.isAvailable(order.itemId) else {
            throw OrderError.outOfStock
        }
        return try await paymentGateway.charge(order.total, method: order.paymentMethod)
    }
}
```

**Correct (compiler enforces all dependencies at init):**

```swift
final class OrderService {
    private let paymentGateway: PaymentProcessing
    private let inventory: InventoryChecking

    init(paymentGateway: PaymentProcessing, inventory: InventoryChecking) { // missing dependency = compile error
        self.paymentGateway = paymentGateway
        self.inventory = inventory
    }

    func placeOrder(_ order: Order) async throws -> Confirmation {
        guard try await inventory.isAvailable(order.itemId) else {
            throw OrderError.outOfStock
        }
        return try await paymentGateway.charge(order.total, method: order.paymentMethod)
    }
}
```
