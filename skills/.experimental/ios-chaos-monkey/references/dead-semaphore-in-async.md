---
title: "Semaphore.wait() Inside Async Context Deadlocks Thread Pool"
impact: HIGH
impactDescription: "thread pool exhaustion deadlock under moderate concurrency"
tags: dead, semaphore, async, thread-pool, cooperative
---

## Semaphore.wait() Inside Async Context Deadlocks Thread Pool

Using `DispatchSemaphore.wait()` inside an `async` function blocks a thread in Swift's cooperative thread pool. The pool has a small fixed size (typically equal to CPU core count). When enough concurrent tasks block on semaphores, the entire pool is consumed and no task can make progress, including the one that would signal the semaphore.

**Incorrect (blocks cooperative thread pool threads with semaphore):**

```swift
import Foundation

class APIClient {
    func fetchSync(url: URL) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data?

        URLSession.shared.dataTask(with: url) { data, _, _ in
            result = data
            semaphore.signal()
        }.resume()

        semaphore.wait()  // blocks a cooperative thread
        return result
    }

    func fetchAll(urls: [URL]) async -> [Data?] {
        await withTaskGroup(of: Data?.self) { group in
            for url in urls {
                group.addTask {
                    self.fetchSync(url: url)  // each task blocks a pool thread
                }
            }
            var results: [Data?] = []
            for await data in group { results.append(data) }
            return results
        }
    }
}
```

**Proof Test (exposes thread pool exhaustion with concurrent semaphore waits):**

```swift
import XCTest
@testable import MyApp

final class APIClientThreadPoolTests: XCTestCase {
    func testFetchAllDoesNotDeadlockUnderLoad() async {
        let client = APIClient()
        let urls = (0..<20).map {
            URL(string: "https://httpbin.org/delay/1?id=\($0)")!
        }
        let expectation = expectation(description: "fetchAll completes")

        Task {
            _ = await client.fetchAll(urls: urls)
            expectation.fulfill()  // never reached — pool exhausted
        }

        await fulfillment(of: [expectation], timeout: 10)
    }
}
```

**Correct (CheckedContinuation bridges callback to async without blocking):**

```swift
import Foundation

class APIClient {
    func fetch(url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error { continuation.resume(throwing: error) }
                else if let data { continuation.resume(returning: data) }
                else { continuation.resume(throwing: URLError(.badServerResponse)) }
            }.resume()  // non-blocking — cooperative thread is free
        }
    }

    func fetchAll(urls: [URL]) async -> [Data?] {
        await withTaskGroup(of: Data?.self) { group in
            for url in urls {
                group.addTask { try? await self.fetch(url: url) }
            }
            var results: [Data?] = []
            for await data in group { results.append(data) }
            return results
        }
    }
}
```
