---
title: "Dispatch Queue Target Hierarchy Inversion Deadlocks"
impact: MEDIUM-HIGH
impactDescription: "intermittent deadlock when queue ordering is violated"
tags: dead, dispatch, queue-hierarchy, target, inversion
---

## Dispatch Queue Target Hierarchy Inversion Deadlocks

When queue A targets queue B (A drains through B), synchronously dispatching from B back to A creates a cycle. Queue B holds its lock while waiting for A, but A needs to drain through B, which is locked. This is an intermittent deadlock because it only triggers when both queues are active simultaneously.

**Incorrect (sync dispatch from write queue to read queue creates cycle):**

```swift
import Foundation

class LayeredCache {
    private let readQueue = DispatchQueue(label: "com.app.cache.read")
    private let writeQueue: DispatchQueue
    private var store: [String: Data] = [:]

    init() {
        writeQueue = DispatchQueue(
            label: "com.app.cache.write",
            target: readQueue  // writeQueue drains through readQueue
        )
    }

    func read(_ key: String) -> Data? {
        readQueue.sync { store[key] }
    }

    func write(_ data: Data, forKey key: String) {
        writeQueue.sync {
            store[key] = data
            _ = read(key)  // deadlock: readQueue.sync from writeQueue's context
        }
    }
}
```

**Proof Test (exposes the hierarchy inversion deadlock):**

```swift
import XCTest
@testable import MyApp

final class LayeredCacheHierarchyTests: XCTestCase {
    func testWriteThenReadDoesNotDeadlock() {
        let cache = LayeredCache()
        let expectation = expectation(description: "write-read completes")

        DispatchQueue.global().async {
            cache.write(Data("test".utf8), forKey: "k1")
            expectation.fulfill()  // never reached — hierarchy inversion
        }

        waitForExpectations(timeout: 3)  // fails — deadlocked
    }
}
```

**Correct (strict hierarchy — never sync-dispatch upward, use internal unsafe read):**

```swift
import Foundation

class LayeredCache {
    private let readQueue = DispatchQueue(label: "com.app.cache.read")
    private let writeQueue: DispatchQueue
    private var store: [String: Data] = [:]

    init() {
        writeQueue = DispatchQueue(
            label: "com.app.cache.write",
            target: readQueue
        )
    }

    func read(_ key: String) -> Data? {
        readQueue.sync { store[key] }
    }

    func write(_ data: Data, forKey key: String) {
        writeQueue.sync {
            store[key] = data
            _ = store[key]  // direct access — already on target queue
        }
    }
}
```
