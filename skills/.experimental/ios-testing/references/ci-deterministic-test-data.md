---
title: "Use Deterministic Test Data Over Random Generation"
impact: LOW-MEDIUM
impactDescription: "eliminates non-reproducible test failures"
tags: ci, deterministic, test-data, reproducibility, seeding
---

## Use Deterministic Test Data Over Random Generation

Tests that call `Date()`, `UUID()`, or `.random()` produce different values on every run, making failures impossible to reproduce locally. Injecting time, identifiers, and random values through protocols yields identical test runs across machines and CI environments, turning every failure into a deterministic, debuggable signal.

**Incorrect (different results on every run):**

```swift
struct OrderService {
    func createOrder(items: [CartItem]) -> Order {
        Order(
            id: UUID().uuidString, // different ID every run — assertions can't match
            items: items,
            createdAt: Date(), // different timestamp every run
            confirmationCode: String(Int.random(in: 100_000...999_999)) // non-reproducible
        )
    }
}

@Suite struct OrderServiceTests {
    @Test func createsOrderFromCart() {
        let service = OrderService()
        let order = service.createOrder(items: [.stub(name: "Dog Collar", quantity: 1)])
        #expect(order.id.isEmpty == false) // can only assert "not empty" — no exact match possible
        #expect(order.confirmationCode.count == 6)
    }
}
```

**Correct (fixed values make assertions exact and reproducible):**

```swift
protocol IdentifierGenerating {
    func generateId() -> String
    func generateConfirmationCode() -> String
}

protocol Clock {
    func now() -> Date
}

struct OrderService {
    let idGenerator: IdentifierGenerating
    let clock: Clock

    func createOrder(items: [CartItem]) -> Order {
        Order(
            id: idGenerator.generateId(),
            items: items,
            createdAt: clock.now(),
            confirmationCode: idGenerator.generateConfirmationCode()
        )
    }
}

struct FixedIdGenerator: IdentifierGenerating {
    func generateId() -> String { "order-001" }
    func generateConfirmationCode() -> String { "123456" }
}

struct FixedClock: Clock {
    func now() -> Date { Date(timeIntervalSince1970: 1_700_000_000) } // 2023-11-14T22:13:20Z
}

@Suite struct OrderServiceTests {
    @Test func createsOrderFromCart() {
        let service = OrderService(idGenerator: FixedIdGenerator(), clock: FixedClock())
        let order = service.createOrder(items: [.stub(name: "Dog Collar", quantity: 1)])
        #expect(order.id == "order-001") // exact match — fails reproduce identically on any machine
        #expect(order.confirmationCode == "123456")
        #expect(order.createdAt == Date(timeIntervalSince1970: 1_700_000_000))
    }
}
```
