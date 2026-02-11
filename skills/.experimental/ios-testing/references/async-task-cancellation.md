---
title: "Test Task Cancellation Paths Explicitly"
impact: MEDIUM
impactDescription: "prevents memory leaks and dangling connections"
tags: async, cancellation, task, cleanup, resource-leaks
---

## Test Task Cancellation Paths Explicitly

Async functions that ignore `Task.isCancelled` or `try Task.checkCancellation()` continue executing after cancellation, leaking network connections, file handles, and database transactions. Explicitly testing the cancellation path verifies that cleanup runs and no work continues after the task is cancelled.

**Incorrect (cancellation path is never tested):**

```swift
final class ImageLoaderTests: XCTestCase {
    func testLoadImage() async throws {
        let loader = ImageLoader(downloader: MockDownloader())

        let image = try await loader.load(url: catalogURL)
        XCTAssertEqual(image.size.width, 800)
        // cancellation path untested — leaked connections go unnoticed in production
    }
}
```

**Correct (cancellation stops work and cleans up):**

```swift
final class ImageLoaderTests: XCTestCase {
    func testLoadImageStopsOnCancellation() async throws {
        let downloader = MockDownloader(delay: .seconds(5))
        let loader = ImageLoader(downloader: downloader)

        let task = Task {
            try await loader.load(url: catalogURL)
        }

        task.cancel() // cancel before the download completes

        do {
            _ = try await task.value
            XCTFail("Expected CancellationError")
        } catch is CancellationError {
            XCTAssertTrue(downloader.wasCancelled) // verifies cleanup ran and resources were released
        }
    }
}
```
