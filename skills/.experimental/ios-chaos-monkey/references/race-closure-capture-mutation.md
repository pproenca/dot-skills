---
title: "Closure Captures Mutable Reference Across Threads"
impact: MEDIUM-HIGH
impactDescription: "unpredictable state corruption when closures execute concurrently"
tags: race, closure, capture, mutation, concurrency
---

## Closure Captures Mutable Reference Across Threads

When a closure captures a `var` by reference and is dispatched to a concurrent queue, multiple closures race on the same memory location. The `+=` operator is a read-modify-write sequence — two closures can read the same value, both increment it, and both write back the same result, losing one update. Under high concurrency, the final count is consistently lower than expected.

**Incorrect (closures capture and mutate the same var concurrently):**

```swift
class BatchProcessor {
    func processItems(_ items: [WorkItem]) async -> Int {
        var completedCount = 0

        await withTaskGroup(of: Void.self) { group in
            for item in items {
                group.addTask {
                    await item.process()
                    completedCount += 1  // captured var — races on read-modify-write
                }
            }
        }

        return completedCount  // consistently less than items.count
    }
}
```

**Proof Test (exposes lost updates from concurrent closure mutation):**

```swift
import XCTest

final class BatchProcessorConcurrencyTests: XCTestCase {
    func testAllItemsAreCounted() async {
        let processor = BatchProcessor()
        let items = (0..<200).map { _ in WorkItem() }

        let count = await processor.processItems(items)

        // With the race, completedCount loses increments — typically 180-195
        XCTAssertEqual(count, items.count, "Expected \(items.count), got \(count)")
    }
}
```

**Correct (TaskGroup with isolated accumulation — no shared mutable state):**

```swift
class BatchProcessor {
    func processItems(_ items: [WorkItem]) async -> Int {
        await withTaskGroup(of: Bool.self, returning: Int.self) { group in
            for item in items {
                group.addTask {
                    await item.process()
                    return true  // each task returns its result — no shared var
                }
            }

            var completedCount = 0
            for await _ in group {
                completedCount += 1  // sequential reduction — no race
            }
            return completedCount
        }
    }
}
```
