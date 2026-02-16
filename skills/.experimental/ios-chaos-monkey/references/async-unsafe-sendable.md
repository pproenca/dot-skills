---
title: "@unchecked Sendable Hides Data Race from Compiler"
impact: MEDIUM-HIGH
impactDescription: "bypasses Swift 6 safety, data race manifests as production crash"
tags: async, sendable, unchecked, data-race, swift6
---

## @unchecked Sendable Hides Data Race from Compiler

Marking a class as `@unchecked Sendable` to silence compiler warnings does not make it thread-safe. It tells the compiler to skip concurrency checks, hiding real data races. The class can be shared freely across isolation boundaries, and concurrent access to its mutable state crashes in production with `EXC_BAD_ACCESS` or produces silently corrupted values.

**Incorrect (unchecked Sendable silences warnings but allows data races):**

```swift
import Foundation

final class SessionStore: @unchecked Sendable {
    var authToken: String = ""
    var userId: String = ""
    var isLoggedIn: Bool = false

    func login(token: String, userId: String) {
        self.authToken = token    // unsynchronized write
        self.userId = userId      // another thread can read mid-update
        self.isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        authToken = ""
        userId = ""
    }

    func currentSession() -> (token: String, userId: String, active: Bool) {
        (authToken, userId, isLoggedIn)  // torn read across 3 properties
    }
}
```

**Proof Test (exposes data race with concurrent login/read under TSan):**

```swift
import XCTest
@testable import MyApp

final class SessionStoreSendableTests: XCTestCase {
    func testConcurrentAccessDoesNotCorruptState() async {
        let store = SessionStore()
        var inconsistencies = 0

        await withTaskGroup(of: Void.self) { group in
            // Writer: alternates login/logout
            group.addTask {
                for i in 0..<500 {
                    if i % 2 == 0 {
                        store.login(token: "tok-\(i)", userId: "usr-\(i)")
                    } else {
                        store.logout()
                    }
                }
            }

            // Reader: checks state consistency
            group.addTask {
                for _ in 0..<500 {
                    let session = store.currentSession()
                    if session.active && session.token.isEmpty {
                        inconsistencies += 1  // logged in but no token
                    }
                }
            }
        }

        // TSan flags this; without TSan, inconsistencies appear ~5-10% of runs
        XCTAssertEqual(inconsistencies, 0, "Detected \(inconsistencies) torn reads")
    }
}
```

**Correct (actor provides real thread safety instead of suppressing warnings):**

```swift
import Foundation

actor SessionStore {
    var authToken: String = ""
    var userId: String = ""
    var isLoggedIn: Bool = false

    func login(token: String, userId: String) {
        self.authToken = token    // actor serializes all access
        self.userId = userId
        self.isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        authToken = ""
        userId = ""
    }

    func currentSession() -> (token: String, userId: String, active: Bool) {
        (authToken, userId, isLoggedIn)  // always consistent
    }
}
```
