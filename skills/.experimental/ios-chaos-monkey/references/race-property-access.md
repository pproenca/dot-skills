---
title: "Unsynchronized Property Read-Write Across Threads"
impact: CRITICAL
impactDescription: "torn reads cause garbage values in 1-3% of accesses"
tags: race, property, torn-read, thread-safety, struct
---

## Unsynchronized Property Read-Write Across Threads

When one thread writes a multi-word struct property while another reads it, the reader can observe a partially-written value — a "torn read." Swift structs larger than a single machine word (e.g., a `String` with pointer + length + flags) are not written atomically. The reader gets half of the old value and half of the new one, producing garbage that crashes downstream code.

**Incorrect (torn reads on unsynchronized struct properties):**

```swift
class UserSession {
    var name: String = ""
    var token: String = ""

    func update(name: String, token: String) {
        self.name = name    // multi-word write — not atomic
        self.token = token  // reader can see new name + old token
    }

    func currentCredentials() -> (String, String) {
        (name, token)  // torn read: partial state visible
    }
}
```

**Proof Test (exposes torn reads from concurrent read-write):**

```swift
import XCTest

final class UserSessionConcurrencyTests: XCTestCase {
    func testConcurrentReadWriteProducesConsistentState() async {
        let session = UserSession()
        let pairs = [
            ("alice", "token-alice"),
            ("bob", "token-bob"),
        ]
        var inconsistencies = 0

        await withTaskGroup(of: Void.self) { group in
            // Writer: alternates between two valid states
            group.addTask {
                for _ in 0..<1000 {
                    let pair = pairs[Int.random(in: 0...1)]
                    session.update(name: pair.0, token: pair.1)
                }
            }

            // Reader: checks that name and token always belong together
            group.addTask {
                for _ in 0..<1000 {
                    let (name, token) = session.currentCredentials()
                    if !name.isEmpty && !token.isEmpty {
                        let valid = pairs.contains(where: { $0.0 == name && $0.1 == token })
                        if !valid { inconsistencies += 1 }
                    }
                }
            }
        }

        // Torn reads produce mismatched name/token combinations
        XCTAssertEqual(inconsistencies, 0, "Detected \(inconsistencies) torn reads")
    }
}
```

**Correct (actor isolation guarantees atomic read-write of all properties):**

```swift
actor UserSession {
    var name: String = ""
    var token: String = ""

    func update(name: String, token: String) {
        self.name = name    // actor ensures exclusive access
        self.token = token  // no interleaving possible
    }

    func currentCredentials() -> (String, String) {
        (name, token)  // always sees a consistent pair
    }
}
```
