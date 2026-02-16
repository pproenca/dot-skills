---
title: "GCD Creates Unbounded Threads Under Concurrent Load"
impact: MEDIUM
impactDescription: "512+ threads created, system kills process"
tags: exhaust, gcd, thread-explosion, dispatch-queue, concurrency
---

## GCD Creates Unbounded Threads Under Concurrent Load

Dispatching blocking work to `.concurrent` queues causes GCD to spawn additional threads when existing ones are blocked. With 500 blocking operations, GCD creates 500+ threads. The kernel enforces a per-process thread limit (~512) and terminates the process when exceeded.

**Incorrect (dispatches blocking work to concurrent queue, causing thread explosion):**

```swift
import Foundation

class DataImporter {
    private let processingQueue = DispatchQueue(
        label: "com.app.import",
        attributes: .concurrent  // GCD spawns threads for each blocked item
    )

    func importAll(records: [Data], completion: @escaping ([String]) -> Void) {
        var results: [String] = []
        let lock = NSLock()

        let group = DispatchGroup()
        for record in records {
            group.enter()
            processingQueue.async {
                // Simulates blocking I/O — GCD spawns a new thread per block
                Thread.sleep(forTimeInterval: 0.1)
                let parsed = self.parse(record)
                lock.lock()
                results.append(parsed)
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    private func parse(_ data: Data) -> String {
        String(data: data, encoding: .utf8) ?? ""
    }
}
```

**Proof Test (exposes thread explosion by dispatching 500 blocking operations):**

```swift
import XCTest

final class DataImporterThreadTests: XCTestCase {
    func testBulkImportDoesNotExplodeThreads() {
        let importer = DataImporter()
        let records = (0..<500).map { Data("record-\($0)".utf8) }

        let expectation = expectation(description: "import complete")
        var threadCountBefore = 0
        var threadCountDuring = 0

        threadCountBefore = currentThreadCount()

        importer.importAll(records: records) { results in
            XCTAssertEqual(results.count, 500)
            expectation.fulfill()
        }

        // Sample thread count during processing
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            threadCountDuring = self.currentThreadCount()
        }

        wait(for: [expectation], timeout: 60)

        let spawned = threadCountDuring - threadCountBefore
        // GCD creates 500+ threads with concurrent queue + blocking work
        XCTAssertLessThan(spawned, 20,
            "Spawned \(spawned) threads — thread explosion detected")
    }

    private func currentThreadCount() -> Int {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        task_threads(mach_task_self_, &threadList, &threadCount)
        return Int(threadCount)
    }
}
```

**Correct (OperationQueue limits concurrent operations, preventing thread explosion):**

```swift
import Foundation

class DataImporter {
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.app.import"
        queue.maxConcurrentOperationCount = 4  // bounded thread count
        return queue
    }()

    func importAll(records: [Data], completion: @escaping ([String]) -> Void) {
        var results: [String] = []
        let lock = NSLock()

        let group = DispatchGroup()
        for record in records {
            group.enter()
            operationQueue.addOperation {
                Thread.sleep(forTimeInterval: 0.1)
                let parsed = self.parse(record)
                lock.lock()
                results.append(parsed)
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    private func parse(_ data: Data) -> String {
        String(data: data, encoding: .utf8) ?? ""
    }
}
```
