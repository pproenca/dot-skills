---
title: "Actor Reentrancy Produces Unexpected Interleaving"
impact: HIGH
impactDescription: "stale state read after await, data corruption in 5-15% of concurrent calls"
tags: dead, actor, reentrancy, interleaving, stale-state
---

## Actor Reentrancy Produces Unexpected Interleaving

Actor methods that contain `await` release the actor's isolation at the suspension point. Other callers can interleave and mutate state between the suspension and resumption. Code that reads state before the `await` and uses it after operates on stale data, leading to invariant violations and data corruption.

**Incorrect (balance read before await is stale after resumption):**

```swift
actor BankAccount {
    var balance: Double = 1000.0

    func transfer(amount: Double, to other: BankAccount) async -> Bool {
        guard balance >= amount else { return false }  // stale check
        // --- actor releases isolation here ---
        let fee = await calculateFee(for: amount)
        // --- another transfer may have drained balance ---
        balance -= (amount + fee)  // can go negative
        await other.deposit(amount)
        return true  // claims success even on stale balance
    }

    func deposit(_ amount: Double) {
        balance += amount
    }

    private func calculateFee(for amount: Double) async -> Double {
        try? await Task.sleep(for: .milliseconds(10))
        return amount * 0.01
    }
}
```

**Proof Test (exposes negative balance and excess transfers from interleaving):**

```swift
import XCTest
@testable import MyApp

final class BankAccountReentrancyTests: XCTestCase {
    func testConcurrentTransfersNeverProduceNegativeBalance() async {
        let account = BankAccount()
        let target = BankAccount()
        var successCount = 0
        let lock = NSLock()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    let ok = await account.transfer(amount: 100, to: target)
                    if ok {
                        lock.lock()
                        successCount += 1
                        lock.unlock()
                    }
                }
            }
        }

        let finalBalance = await account.balance
        // 20 transfers of 100 from 1000 balance — at most 10 should succeed
        XCTAssertGreaterThanOrEqual(finalBalance, 0, "Balance went negative: \(finalBalance)")
        XCTAssertLessThanOrEqual(successCount, 10, "Too many transfers succeeded: \(successCount)")
    }
}
```

**Correct (re-check state after await, return success to caller):**

```swift
actor BankAccount {
    var balance: Double = 1000.0

    func transfer(amount: Double, to other: BankAccount) async -> Bool {
        guard balance >= amount else { return false }
        let fee = await calculateFee(for: amount)
        let total = amount + fee
        guard balance >= total else { return false }  // re-check after await
        balance -= total
        await other.deposit(amount)
        return true  // caller knows the transfer succeeded
    }

    func deposit(_ amount: Double) {
        balance += amount
    }

    private func calculateFee(for amount: Double) async -> Double {
        try? await Task.sleep(for: .milliseconds(10))
        return amount * 0.01
    }
}
```
