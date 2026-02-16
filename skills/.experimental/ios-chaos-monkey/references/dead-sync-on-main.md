---
title: "DispatchQueue.main.sync from Main Thread Deadlocks Instantly"
impact: HIGH
impactDescription: "100% deadlock, watchdog kills app within 10 seconds"
tags: dead, dispatch, main-thread, sync, watchdog
---

## DispatchQueue.main.sync from Main Thread Deadlocks Instantly

Calling `DispatchQueue.main.sync` while already on the main thread deadlocks immediately. The sync call blocks the current (main) thread waiting for the submitted block to execute on the main queue, but the main queue cannot execute anything because the main thread is blocked waiting. The watchdog terminates the app after 10 seconds of unresponsive main thread.

**Incorrect (deadlocks instantly when called from main thread):**

```swift
import Foundation

class UIFormatter {
    func formatForDisplay(_ value: Double) -> String {
        var result = ""
        DispatchQueue.main.sync {  // deadlock: main thread waits for itself
            result = String(format: "%.2f", value)
        }
        return result
    }

    func updateLabel(with value: Double) {
        let text = formatForDisplay(value)  // called from main thread
        print("Formatted: \(text)")         // never reached
    }
}
```

**Proof Test (exposes the deadlock — completion never fires within timeout):**

```swift
import XCTest
@testable import MyApp

final class UIFormatterDeadlockTests: XCTestCase {
    func testFormatDoesNotDeadlockOnMainThread() {
        let formatter = UIFormatter()
        let expectation = expectation(description: "format completes")

        DispatchQueue.main.async {
            let result = formatter.formatForDisplay(42.195)
            XCTAssertEqual(result, "42.20")
            expectation.fulfill()  // never reached with incorrect code
        }

        waitForExpectations(timeout: 3)  // fails — deadlocked
    }
}
```

**Correct (MainActor isolation avoids the sync dispatch entirely):**

```swift
import Foundation

class UIFormatter {
    @MainActor
    func formatForDisplay(_ value: Double) -> String {
        String(format: "%.2f", value)  // already on main — no dispatch needed
    }

    @MainActor
    func updateLabel(with value: Double) {
        let text = formatForDisplay(value)
        print("Formatted: \(text)")
    }
}
```
