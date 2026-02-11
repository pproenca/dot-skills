---
title: "Use @testable import Sparingly"
impact: HIGH
impactDescription: "prevents coupling tests to internal implementation"
tags: arch, testable-import, encapsulation, api-surface
---

## Use @testable import Sparingly

`@testable import` exposes `internal` symbols to test targets, tempting you to test private implementation details. When those internals change, tests break even though the public behavior is identical. Prefer testing through the public API and reserve `@testable` for cases where no public surface exists.

**Incorrect (tests break when internal cache strategy changes):**

```swift
@testable import Networking

final class ImageLoaderTests: XCTestCase {
    func testImageIsCached() async throws {
        let loader = ImageLoader()
        _ = try await loader.loadImage(from: thumbnailURL)

        let cached = loader.memoryCache.object(forKey: thumbnailURL.absoluteString as NSString) // coupled to internal cache type
        XCTAssertNotNil(cached)
    }

    func testPendingRequestTracking() async throws {
        let loader = ImageLoader()
        async let _ = loader.loadImage(from: thumbnailURL)

        XCTAssertTrue(loader.pendingRequests.contains(thumbnailURL)) // breaks if pendingRequests is renamed or restructured
    }
}
```

**Correct (tests verify observable behavior, survive refactors):**

```swift
import Networking

final class ImageLoaderTests: XCTestCase {
    func testImageIsCached() async throws {
        let loader = ImageLoader()
        let first = try await loader.loadImage(from: thumbnailURL)
        let second = try await loader.loadImage(from: thumbnailURL)

        XCTAssertEqual(first.pngData(), second.pngData()) // verifies caching through public API
    }

    func testDuplicateRequestsCoalesced() async throws {
        let loader = ImageLoader()
        async let imageA = loader.loadImage(from: thumbnailURL)
        async let imageB = loader.loadImage(from: thumbnailURL)

        let (a, b) = try await (imageA, imageB)
        XCTAssertEqual(a.pngData(), b.pngData()) // tests coalescing without touching internals
    }
}
```
