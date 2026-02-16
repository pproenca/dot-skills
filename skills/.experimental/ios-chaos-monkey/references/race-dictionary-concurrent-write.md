---
title: "Concurrent Dictionary Mutation Crashes with EXC_BAD_ACCESS"
impact: CRITICAL
impactDescription: "EXC_BAD_ACCESS on 1-5% of concurrent writes"
tags: race, dictionary, concurrency, exc-bad-access, thread-safety
---

## Concurrent Dictionary Mutation Crashes with EXC_BAD_ACCESS

Two threads writing to the same `Dictionary` simultaneously corrupts the internal hash table. Swift dictionaries are value types with copy-on-write semantics, but the COW reference count check is not atomic — concurrent mutations trigger a buffer reallocation while another thread is mid-write, resulting in `EXC_BAD_ACCESS`.

**Incorrect (crashes under concurrent writes to unprotected dictionary):**

```swift
class ImageCache {
    private var store: [String: Data] = [:]

    func set(_ data: Data, forKey key: String) {
        store[key] = data  // COW buffer mutation — not thread-safe
    }

    func get(_ key: String) -> Data? {
        store[key]
    }

    func clear() {
        store.removeAll()
    }
}
```

**Proof Test (exposes the crash with 100 concurrent writes):**

```swift
import XCTest

final class ImageCacheConcurrencyTests: XCTestCase {
    func testConcurrentWritesDoNotCrash() async {
        let cache = ImageCache()
        let iterations = 100

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let data = Data("image-\(i)".utf8)
                    cache.set(data, forKey: "key-\(i)")  // races here
                }
            }
        }

        // If we reach this line without EXC_BAD_ACCESS, the test passes.
        // With the incorrect code, this crashes ~1-5% of runs.
        let result = cache.get("key-0")
        XCTAssertNotNil(result)
    }
}
```

**Correct (actor isolation serializes all access — eliminates the race):**

```swift
actor ImageCache {
    private var store: [String: Data] = [:]

    func set(_ data: Data, forKey key: String) {
        store[key] = data  // actor serializes access — safe
    }

    func get(_ key: String) -> Data? {
        store[key]
    }

    func clear() {
        store.removeAll()
    }
}
```
