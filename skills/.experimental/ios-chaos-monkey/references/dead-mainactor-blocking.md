---
title: "Blocking MainActor with Synchronous Heavy Work"
impact: MEDIUM-HIGH
impactDescription: "UI freeze >16ms causes dropped frames, >10s triggers watchdog kill"
tags: dead, main-actor, blocking, ui-freeze, watchdog
---

## Blocking MainActor with Synchronous Heavy Work

Performing heavy computation or synchronous I/O on `@MainActor` blocks the entire UI run loop. At 60 FPS the frame budget is 16ms. Any synchronous work exceeding that causes dropped frames; work exceeding 10 seconds triggers the iOS watchdog, which kills the process with no crash report in standard tooling.

**Incorrect (heavy computation blocks the main thread for seconds):**

```swift
import Foundation

@MainActor
class ReportGenerator {
    var reportText: String = ""

    func generateReport(from entries: [String]) {
        var result = ""
        for entry in entries {
            // Simulates heavy per-row processing — 100k entries = ~3-5 seconds
            result += processEntry(entry)
        }
        reportText = result  // UI frozen until this completes
    }

    private func processEntry(_ entry: String) -> String {
        (0..<1000).reduce("") { acc, _ in acc + entry.hash.description }
    }
}
```

**Proof Test (exposes main thread blockage exceeding frame budget):**

```swift
import XCTest
@testable import MyApp

final class ReportGeneratorBlockingTests: XCTestCase {
    @MainActor
    func testGenerateReportDoesNotBlockMainThread() async {
        let generator = ReportGenerator()
        let entries = (0..<10_000).map { "entry-\($0)" }

        let start = CFAbsoluteTimeGetCurrent()
        generator.generateReport(from: entries)
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        // Main thread blocked for the entire duration — UI completely frozen
        XCTAssertLessThan(elapsed, 0.016, "Main thread blocked for \(elapsed)s")
    }
}
```

**Correct (offload heavy work to detached task, update UI on completion):**

```swift
import Foundation

@MainActor
class ReportGenerator {
    var reportText: String = ""

    func generateReport(from entries: [String]) async {
        let result = await Task.detached(priority: .userInitiated) {
            var text = ""
            for entry in entries {
                text += self.processEntry(entry)  // runs off main thread
            }
            return text
        }.value
        reportText = result  // back on MainActor for UI update
    }

    nonisolated private func processEntry(_ entry: String) -> String {
        (0..<1000).reduce("") { acc, _ in acc + entry.hash.description }
    }
}
```
