---
title: "Concurrent Array Append Corrupts Internal Buffer"
impact: CRITICAL
impactDescription: "heap corruption on ~2% of concurrent appends"
tags: race, array, concurrency, heap-corruption, buffer
---

## Concurrent Array Append Corrupts Internal Buffer

Multiple threads appending to the same `Array` can trigger simultaneous buffer reallocations. When the array's capacity is exceeded, Swift allocates a new buffer, copies elements, and frees the old one — if two threads hit this path simultaneously, one thread writes into a freed buffer, corrupting the heap.

**Incorrect (crashes when concurrent appends trigger buffer reallocation):**

```swift
class EventLogger {
    private var events: [String] = []

    func log(_ event: String) {
        events.append(event)  // buffer reallocation is not atomic
    }

    func allEvents() -> [String] {
        events
    }

    func reset() {
        events.removeAll()
    }
}
```

**Proof Test (exposes heap corruption with 50 concurrent appends):**

```swift
import XCTest

final class EventLoggerConcurrencyTests: XCTestCase {
    func testConcurrentAppendsDoNotCorruptBuffer() async {
        let logger = EventLogger()
        let iterations = 50

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    logger.log("event-\(i)")  // races on buffer reallocation
                }
            }
        }

        let events = logger.allEvents()
        // With the incorrect code, count is unpredictable — some appends
        // write into freed memory and are lost or the process crashes.
        XCTAssertEqual(events.count, iterations)
    }
}
```

**Correct (actor isolation guarantees sequential appends — no buffer races):**

```swift
actor EventLogger {
    private var events: [String] = []

    func log(_ event: String) {
        events.append(event)  // actor serializes — one append at a time
    }

    func allEvents() -> [String] {
        events
    }

    func reset() {
        events.removeAll()
    }
}
```
