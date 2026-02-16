---
title: "Detached Task Without Cancellation Handle Leaks Work"
impact: HIGH
impactDescription: "orphaned background work accumulates, crashes under memory pressure"
tags: async, detached-task, leak, cancellation, memory
---

## Detached Task Without Cancellation Handle Leaks Work

`Task.detached { ... }` returns a `Task` handle that, when discarded, leaves the work running with no way to cancel it. Each navigation cycle spawns a new detached task while old ones continue in the background. Under memory pressure, the accumulated work causes the app to exceed its memory budget and be terminated by the system.

**Incorrect (discards Task handle, orphaned syncs accumulate):**

```swift
import Foundation

class SyncManager {
    func startPeriodicSync() {
        Task.detached {  // handle discarded — no way to cancel
            while true {
                await self.performSync()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    func performSync() async {
        // Simulates fetching and processing server data
        try? await Task.sleep(for: .seconds(2))
        print("Sync completed at \(Date())")
    }
}
```

**Proof Test (exposes orphaned task accumulation across multiple starts):**

```swift
import XCTest
@testable import MyApp

final class SyncManagerLeakTests: XCTestCase {
    func testStopCancelsPeriodicSync() async throws {
        var syncCount = 0
        let manager = SyncManager()

        // Simulate 3 navigation cycles, each starting a new sync
        for _ in 0..<3 {
            manager.startPeriodicSync()
        }

        try await Task.sleep(for: .seconds(5))
        // With incorrect code, 3 syncs are running concurrently
        // There is no way to stop them — they accumulate forever
        XCTFail("No mechanism to cancel orphaned tasks")
    }
}
```

**Correct (stores Task handle, cancels in stop/deinit):**

```swift
import Foundation

class SyncManager {
    private var syncTask: Task<Void, Never>?

    func startPeriodicSync() {
        syncTask?.cancel()  // cancel previous sync before starting new one
        syncTask = Task.detached { [weak self] in
            while !Task.isCancelled {
                await self?.performSync()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    func stopSync() {
        syncTask?.cancel()
        syncTask = nil
    }

    func performSync() async {
        try? await Task.sleep(for: .seconds(2))
        print("Sync completed at \(Date())")
    }

    deinit { syncTask?.cancel() }
}
```
