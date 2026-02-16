---
title: "Non-Atomic Bool Flag Creates Check-Then-Act Race"
impact: HIGH
impactDescription: "duplicate execution in 2-8% of concurrent calls"
tags: race, bool, check-then-act, atomicity, flag
---

## Non-Atomic Bool Flag Creates Check-Then-Act Race

Reading a `Bool`, checking it, and then setting it is three separate operations — not one. When multiple threads execute this check-then-act sequence simultaneously, they all read `false`, all pass the guard, and all proceed to execute the protected code. For payment processing or network requests, this means duplicate charges or duplicate API calls.

**Incorrect (check-then-act race allows duplicate payment processing):**

```swift
class PaymentProcessor {
    private var isProcessing = false

    func processPayment(amount: Decimal) async throws -> Receipt {
        guard !isProcessing else {  // Thread A reads false
            throw PaymentError.alreadyProcessing
        }
        isProcessing = true  // Thread B also read false — both continue

        defer { isProcessing = false }
        return try await chargeCard(amount: amount)  // charged twice
    }

    private func chargeCard(amount: Decimal) async throws -> Receipt {
        try await Task.sleep(for: .milliseconds(100))
        return Receipt(amount: amount)
    }
}
```

**Proof Test (exposes duplicate execution from concurrent process calls):**

```swift
import XCTest

final class PaymentProcessorConcurrencyTests: XCTestCase {
    func testConcurrentPaymentsProcessExactlyOnce() async throws {
        let processor = PaymentProcessor()
        var successes = 0
        var rejections = 0
        let lock = NSLock()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    do {
                        _ = try await processor.processPayment(amount: 99.99)
                        lock.lock()
                        successes += 1
                        lock.unlock()
                    } catch {
                        lock.lock()
                        rejections += 1
                        lock.unlock()
                    }
                }
            }
        }

        // With the race, multiple tasks slip past the guard
        XCTAssertEqual(successes, 1, "Expected 1 success, got \(successes)")
        XCTAssertEqual(rejections, 9, "Expected 9 rejections, got \(rejections)")
    }
}
```

**Correct (actor isolation makes check-then-act atomic):**

```swift
actor PaymentProcessor {
    private var isProcessing = false

    func processPayment(amount: Decimal) async throws -> Receipt {
        // Reentrancy-safe: guard + set run synchronously before any
        // suspension point, so actor isolation makes them atomic.
        guard !isProcessing else {
            throw PaymentError.alreadyProcessing
        }
        isProcessing = true

        defer { isProcessing = false }
        return try await chargeCard(amount: amount)  // only one caller reaches here
    }

    private func chargeCard(amount: Decimal) async throws -> Receipt {
        try await Task.sleep(for: .milliseconds(100))
        return Receipt(amount: amount)
    }
}
```

**Alternative (stored Task coalesces concurrent callers into one result):**

When concurrent callers should receive the same result instead of an error, store the in-flight `Task` and let subsequent callers await it:

```swift
actor PaymentProcessor {
    private var inFlightTask: Task<Receipt, Error>?

    func processPayment(amount: Decimal) async throws -> Receipt {
        if let existing = inFlightTask {
            return try await existing.value  // share in-flight result
        }
        let task = Task { try await self.chargeCard(amount: amount) }
        inFlightTask = task
        defer { inFlightTask = nil }
        return try await task.value
    }

    private func chargeCard(amount: Decimal) async throws -> Receipt {
        try await Task.sleep(for: .milliseconds(100))
        return Receipt(amount: amount)
    }
}
```
