---
title: "Missing Task.isCancelled Check Wastes Resources After Navigation"
impact: HIGH
impactDescription: "background work continues 10-60s after screen dismissal"
tags: async, cancellation, task, resource-waste, navigation
---

## Missing Task.isCancelled Check Wastes Resources After Navigation

A long-running task loop that never checks `Task.isCancelled` continues to fetch and process data long after the user has navigated away. The work consumes CPU, memory, and network bandwidth for results that will be discarded, draining battery and overwriting state that the new screen depends on.

**Incorrect (download loop ignores cancellation, runs until complete):**

```swift
import Foundation

class ImageDownloader {
    func downloadBatch(urls: [URL]) async throws -> [Data] {
        var results: [Data] = []
        for url in urls {
            // No cancellation check — continues after task is cancelled
            let (data, _) = try await URLSession.shared.data(from: url)
            results.append(data)
        }
        return results
    }
}
```

**Proof Test (exposes that work continues after cancellation):**

```swift
import XCTest
@testable import MyApp

final class ImageDownloaderCancellationTests: XCTestCase {
    func testDownloadStopsAfterCancellation() async throws {
        let downloader = ImageDownloader()
        let urls = (0..<100).map {
            URL(string: "https://httpbin.org/bytes/1024?id=\($0)")!
        }
        var downloadedCount = 0

        let task = Task {
            let results = try await downloader.downloadBatch(urls: urls)
            downloadedCount = results.count
        }

        try await Task.sleep(for: .milliseconds(200))
        task.cancel()
        try await Task.sleep(for: .seconds(3))

        // With incorrect code, all 100 downloads complete despite cancellation
        XCTAssertLessThan(downloadedCount, urls.count, "Work continued after cancel")
    }
}
```

**Correct (checkCancellation at each iteration stops work promptly):**

```swift
import Foundation

class ImageDownloader {
    func downloadBatch(urls: [URL]) async throws -> [Data] {
        var results: [Data] = []
        for url in urls {
            try Task.checkCancellation()  // throws if task was cancelled
            let (data, _) = try await URLSession.shared.data(from: url)
            results.append(data)
        }
        return results
    }
}
```
