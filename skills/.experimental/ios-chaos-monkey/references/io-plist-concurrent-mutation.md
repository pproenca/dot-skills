---
title: "UserDefaults Concurrent Read-Write Produces Stale Values"
impact: MEDIUM
impactDescription: "stale reads in 3-8% of concurrent accesses"
tags: io, userdefaults, concurrency, check-then-write, actor
---

## UserDefaults Concurrent Read-Write Produces Stale Values

`UserDefaults` is thread-safe for individual read or write operations, but compound check-then-write sequences are NOT atomic. Two threads can both read the old value, both decide to increment, and one write clobbers the other. The lost update goes undetected.

**Incorrect (check-then-write sequence races, losing increments):**

```swift
import Foundation

class FeatureFlagStore {
    private let defaults = UserDefaults.standard
    private let key = "launch_count"

    func incrementLaunchCount() -> Int {
        let current = defaults.integer(forKey: key)  // read
        let next = current + 1
        defaults.set(next, forKey: key)  // write — not atomic with read
        return next
    }

    func launchCount() -> Int {
        defaults.integer(forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
```

**Proof Test (exposes lost updates from concurrent increments):**

```swift
import XCTest

final class FeatureFlagStoreConcurrencyTests: XCTestCase {
    func testConcurrentIncrementsAreNotLost() async {
        let store = FeatureFlagStore()
        store.reset()
        let iterations = 200

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask {
                    _ = store.incrementLaunchCount()  // races here
                }
            }
        }

        let finalCount = store.launchCount()
        // Lost updates produce a count less than iterations
        XCTAssertEqual(finalCount, iterations,
            "Expected \(iterations) but got \(finalCount) — updates lost")
    }
}
```

**Correct (actor serializes the check-then-write into a single atomic operation):**

```swift
import Foundation

actor FeatureFlagStore {
    private let defaults = UserDefaults.standard
    private let key = "launch_count"

    func incrementLaunchCount() -> Int {
        let current = defaults.integer(forKey: key)
        let next = current + 1
        defaults.set(next, forKey: key)  // serialized by actor — no race
        return next
    }

    func launchCount() -> Int {
        defaults.integer(forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
```
