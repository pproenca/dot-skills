---
title: "Collection Mutation During Enumeration Crashes at Runtime"
impact: MEDIUM
impactDescription: "NSInternalInconsistencyException, 100% crash on mutation during for-in"
tags: mut, collection, enumeration, mutation, crash
---

## Collection Mutation During Enumeration Crashes at Runtime

Modifying a collection while iterating over it invalidates the iterator. With Swift arrays bridged from `NSMutableArray` or accessed concurrently, this triggers an `NSInternalInconsistencyException`. Even pure Swift arrays crash when a captured reference is mutated from another closure during enumeration.

**Incorrect (removes elements during for-in enumeration, crashing):**

```swift
import Foundation

class EventBus {
    private var handlers: [String: [() -> Void]] = [:]

    func register(event: String, handler: @escaping () -> Void) {
        handlers[event, default: []].append(handler)
    }

    func emit(event: String) {
        guard let eventHandlers = handlers[event] else { return }
        for handler in eventHandlers {
            handler()
        }
    }

    func removeAll(for event: String) {
        handlers[event]?.removeAll()  // mutation during enumeration if called from handler
    }

    func emitAndCleanup(event: String) {
        guard let eventHandlers = handlers[event] else { return }
        for handler in eventHandlers {
            handler()
            // Mutating handlers mid-iteration — crash
            handlers[event]?.removeFirst()
        }
    }
}
```

**Proof Test (exposes crash when mutating collection during iteration):**

```swift
import XCTest

final class EventBusMutationTests: XCTestCase {
    func testEmitAndCleanupDoesNotCrash() {
        let bus = EventBus()
        var callCount = 0

        for _ in 0..<5 {
            bus.register(event: "load") {
                callCount += 1
            }
        }

        // emitAndCleanup mutates the array mid-iteration — crash
        XCTAssertNoThrow(bus.emitAndCleanup(event: "load"))
        XCTAssertEqual(callCount, 5,
            "All handlers should have been called before cleanup")
    }
}
```

**Correct (copies handlers before iterating, then clears safely):**

```swift
import Foundation

class EventBus {
    private var handlers: [String: [() -> Void]] = [:]

    func register(event: String, handler: @escaping () -> Void) {
        handlers[event, default: []].append(handler)
    }

    func emit(event: String) {
        guard let eventHandlers = handlers[event] else { return }
        for handler in eventHandlers {
            handler()
        }
    }

    func removeAll(for event: String) {
        handlers[event]?.removeAll()
    }

    func emitAndCleanup(event: String) {
        let snapshot = handlers[event] ?? []  // copy before iterating
        handlers[event]?.removeAll()  // mutate the original safely
        for handler in snapshot {
            handler()
        }
    }
}
```
