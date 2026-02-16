---
title: "Non-Atomic Singleton Exposes Partially Constructed State"
impact: HIGH
impactDescription: "partial initialization observed by early callers in <1% of launches"
tags: race, singleton, initialization, static, partial-state
---

## Non-Atomic Singleton Exposes Partially Constructed State

A hand-rolled singleton using a mutable `static var` with a nil check is not atomic. Two threads can both pass the nil check, both call the initializer, and one thread receives a reference to an instance that the other thread then overwrites — or worse, one thread reads the instance while setup is still in progress, observing partially initialized state.

**Incorrect (hand-rolled singleton exposes partially constructed state):**

```swift
class Configuration {
    static var _shared: Configuration?

    static var shared: Configuration {
        if _shared == nil {
            _shared = Configuration()  // two threads can both enter here
        }
        return _shared!
    }

    var apiBaseURL: String = ""
    var maxRetries: Int = 0

    private init() {
        // Simulate slow setup — widens the race window
        apiBaseURL = "https://api.example.com"
        maxRetries = 3
    }
}
```

**Proof Test (exposes partial initialization from 100 concurrent accesses):**

```swift
import XCTest

final class ConfigurationSingletonTests: XCTestCase {
    func testConcurrentAccessReturnsSameFullyInitializedInstance() async {
        var instances: [ObjectIdentifier] = []
        var partialReads = 0
        let lock = NSLock()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    let config = Configuration.shared
                    let id = ObjectIdentifier(config)

                    // Check for partially initialized state
                    let isPartial = config.apiBaseURL.isEmpty || config.maxRetries == 0

                    lock.lock()
                    instances.append(id)
                    if isPartial { partialReads += 1 }
                    lock.unlock()
                }
            }
        }

        let uniqueInstances = Set(instances)
        XCTAssertEqual(uniqueInstances.count, 1, "Created \(uniqueInstances.count) instances")
        XCTAssertEqual(partialReads, 0, "Observed \(partialReads) partial reads")
    }
}
```

**Correct (static let — Swift guarantees atomic one-time initialization):**

```swift
class Configuration {
    // static let uses dispatch_once under the hood — thread-safe by design
    static let shared = Configuration()

    let apiBaseURL: String
    let maxRetries: Int

    private init() {
        apiBaseURL = "https://api.example.com"
        maxRetries = 3
    }
}
```
