---
title: "Excessive MainActor Hops in Hot Loop Starve UI Updates"
impact: MEDIUM-HIGH
impactDescription: "UI unresponsive for 200ms-2s during batch processing"
tags: async, main-actor, hop, starvation, batching
---

## Excessive MainActor Hops in Hot Loop Starve UI Updates

Awaiting a `@MainActor` method inside a tight loop causes one context switch per iteration. Each hop enqueues work on the main run loop, starving UIKit event handling, scroll rendering, and animation callbacks. For 1000 items, the accumulated overhead of 1000 actor hops makes the UI unresponsive for hundreds of milliseconds to seconds.

**Incorrect (one MainActor hop per item starves the run loop):**

```swift
import Foundation

@MainActor
class DataSynchronizer {
    var items: [String] = []
    var progress: Double = 0.0

    func syncFromServer() async throws {
        let fetched = try await fetchItems()
        for (index, item) in fetched.enumerated() {
            await updateUI(item: item, index: index, total: fetched.count)
        }
    }

    func updateUI(item: String, index: Int, total: Int) {
        items.append(item)
        progress = Double(index + 1) / Double(total)  // hop per item
    }

    nonisolated func fetchItems() async throws -> [String] {
        (0..<1000).map { "item-\($0)" }
    }
}
```

**Proof Test (exposes run loop starvation during batch sync):**

```swift
import XCTest
@testable import MyApp

final class DataSynchronizerHopTests: XCTestCase {
    @MainActor
    func testSyncDoesNotStarveRunLoop() async throws {
        let synchronizer = DataSynchronizer()
        var runLoopTicks = 0

        // Count run loop ticks during sync — should stay responsive
        let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            runLoopTicks += 1
        }

        let start = CFAbsoluteTimeGetCurrent()
        try await synchronizer.syncFromServer()
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        timer.invalidate()

        // With incorrect code, timer barely fires — run loop starved
        XCTAssertGreaterThan(runLoopTicks, 5, "Run loop starved: only \(runLoopTicks) ticks")
        XCTAssertLessThan(elapsed, 0.5, "Sync took \(elapsed)s — too slow")
    }
}
```

**Correct (batch items, single MainActor hop to update UI):**

```swift
import Foundation

@MainActor
class DataSynchronizer {
    var items: [String] = []
    var progress: Double = 0.0

    func syncFromServer() async throws {
        let fetched = try await fetchItems()
        await updateUIBatch(items: fetched)  // single hop for all items
    }

    func updateUIBatch(items newItems: [String]) {
        items.append(contentsOf: newItems)  // one update, one hop
        progress = 1.0
    }

    nonisolated func fetchItems() async throws -> [String] {
        (0..<1000).map { "item-\($0)" }
    }
}
```
