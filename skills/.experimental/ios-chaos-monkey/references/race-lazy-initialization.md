---
title: "Lazy Property Double-Initialization Under Concurrency"
impact: HIGH
impactDescription: "double resource allocation, potential crash on non-idempotent init"
tags: race, lazy, initialization, concurrency, double-init
---

## Lazy Property Double-Initialization Under Concurrency

Swift's `lazy var` is not thread-safe. When two threads access an uninitialized lazy property simultaneously, both evaluate the initializer — producing two instances where only one should exist. For non-idempotent resources like database connections or file handles, this causes resource leaks, data corruption, or crashes when the second instance conflicts with the first.

**Incorrect (double initialization when lazy var is accessed concurrently):**

```swift
class DatabaseConnectionPool {
    // lazy var is NOT thread-safe — two threads can both trigger init
    lazy var pool: ConnectionPool = {
        ConnectionPool(maxConnections: 5)  // opens file handles, acquires locks
    }()

    func execute(_ query: String) -> Result<[Row], Error> {
        pool.run(query)
    }
}
```

**Proof Test (exposes double initialization from 10 concurrent accesses):**

```swift
import XCTest

final class DatabaseConnectionPoolTests: XCTestCase {
    func testConcurrentAccessInitializesPoolExactlyOnce() async {
        let db = DatabaseConnectionPool()
        var poolIdentities: [ObjectIdentifier] = []
        let lock = NSLock()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    let identity = ObjectIdentifier(db.pool)
                    lock.lock()
                    poolIdentities.append(identity)
                    lock.unlock()
                }
            }
        }

        let uniquePools = Set(poolIdentities)
        // With lazy var, multiple unique instances appear — double init
        XCTAssertEqual(uniquePools.count, 1, "Pool initialized \(uniquePools.count) times")
    }
}
```

**Correct (actor-isolated computed property with stored state — single initialization guaranteed):**

```swift
actor DatabaseConnectionPool {
    private var _pool: ConnectionPool?

    var pool: ConnectionPool {
        if _pool == nil {
            _pool = ConnectionPool(maxConnections: 5)  // runs at most once
        }
        return _pool!
    }

    func execute(_ query: String) -> Result<[Row], Error> {
        pool.run(query)
    }
}
```
