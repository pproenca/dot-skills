---
title: "Recursive Lock Acquisition on Same Serial Queue"
impact: HIGH
impactDescription: "instant deadlock when method A calls method B on same queue"
tags: dead, serial-queue, recursive, dispatch, sync
---

## Recursive Lock Acquisition on Same Serial Queue

When two methods both dispatch synchronously to the same serial queue, calling one from within the other creates a deadlock. The outer sync block holds the queue, and the inner sync block waits for the queue to become available, which never happens because the outer block is still executing.

**Incorrect (deadlocks when read() is called inside write()):**

```swift
import Foundation

class CacheCoordinator {
    private let queue = DispatchQueue(label: "com.app.cache")
    private var store: [String: Data] = [:]

    func write(_ data: Data, forKey key: String) {
        queue.sync {
            store[key] = data
            let exists = read(key)  // deadlock: queue.sync inside queue.sync
            print("Written, exists: \(exists != nil)")
        }
    }

    func read(_ key: String) -> Data? {
        queue.sync {  // blocks forever — queue already held by write()
            store[key]
        }
    }
}
```

**Proof Test (exposes the deadlock — nested call never completes):**

```swift
import XCTest
@testable import MyApp

final class CacheCoordinatorDeadlockTests: XCTestCase {
    func testWriteThenReadDoesNotDeadlock() {
        let cache = CacheCoordinator()
        let expectation = expectation(description: "write completes")

        DispatchQueue.global().async {
            cache.write(Data("value".utf8), forKey: "key1")
            expectation.fulfill()  // never reached with incorrect code
        }

        waitForExpectations(timeout: 3)  // fails — deadlocked
    }
}
```

**Correct (private unsynchronized methods avoid recursive queue entry):**

```swift
import Foundation

class CacheCoordinator {
    private let queue = DispatchQueue(label: "com.app.cache")
    private var store: [String: Data] = [:]

    func write(_ data: Data, forKey key: String) {
        queue.sync {
            _write(data, forKey: key)
            let exists = _read(key)  // no queue.sync — already inside queue
            print("Written, exists: \(exists != nil)")
        }
    }

    func read(_ key: String) -> Data? {
        queue.sync { _read(key) }
    }

    private func _write(_ data: Data, forKey key: String) {
        store[key] = data
    }

    private func _read(_ key: String) -> Data? {
        store[key]  // unsynchronized — caller must be on queue
    }
}
```
