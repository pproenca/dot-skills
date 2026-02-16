---
title: "TaskGroup Silently Drops Child Task Errors"
impact: HIGH
impactDescription: "failed operations invisible to caller, data inconsistency"
tags: async, task-group, error-handling, silent-failure, concurrency
---

## TaskGroup Silently Drops Child Task Errors

When a `ThrowingTaskGroup` child throws an error, the error is only surfaced if the parent iterates through all results with `for try await`. If the parent only calls `group.addTask` without iterating, or breaks out of iteration early, thrown errors are silently discarded. The caller believes all operations succeeded while some failed, leading to data inconsistency.

**Incorrect (never iterates group results, child errors are swallowed):**

```swift
import Foundation

class BatchUploader {
    func uploadAll(items: [Data], to url: URL) async throws -> Int {
        var successCount = 0

        try await withThrowingTaskGroup(of: Bool.self) { group in
            for item in items {
                group.addTask {
                    try await self.upload(item, to: url)  // error thrown here
                    return true
                }
            }
            // Never iterates — child errors silently dropped
            successCount = items.count  // assumes all succeeded
        }

        return successCount
    }

    private func upload(_ data: Data, to url: URL) async throws -> Void {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
```

**Proof Test (exposes that errors are invisible to the caller):**

```swift
import XCTest
@testable import MyApp

final class BatchUploaderErrorTests: XCTestCase {
    func testFailedUploadsAreReportedNotSwallowed() async throws {
        let uploader = BatchUploader()
        let items = (0..<10).map { Data("item-\($0)".utf8) }
        let badURL = URL(string: "https://httpbin.org/status/500")!

        let count = try await uploader.uploadAll(items: items, to: badURL)
        // With incorrect code, count is 10 even though all uploads failed
        XCTAssertEqual(count, 0, "Reported \(count) successes but all should fail")
    }
}
```

**Correct (iterates all child results, counts only actual successes):**

```swift
import Foundation

class BatchUploader {
    func uploadAll(items: [Data], to url: URL) async throws -> Int {
        var successCount = 0

        try await withThrowingTaskGroup(of: Bool.self) { group in
            for item in items {
                group.addTask {
                    try await self.upload(item, to: url)
                    return true
                }
            }
            for try await success in group {  // surfaces every child error
                if success { successCount += 1 }
            }
        }

        return successCount
    }

    private func upload(_ data: Data, to url: URL) async throws -> Void {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
```
