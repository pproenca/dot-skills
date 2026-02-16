---
title: "Low Memory Warning Ignored Triggers Jetsam Kill"
impact: LOW-MEDIUM
impactDescription: "app terminated by system with no crash log"
tags: exhaust, memory-warning, jetsam, cache, termination
---

## Low Memory Warning Ignored Triggers Jetsam Kill

When iOS sends `UIApplication.didReceiveMemoryWarningNotification`, apps that do not shed cached data are killed by the Jetsam reaper. This produces no crash log and no stack trace. Users see the app restart from scratch with no explanation.

**Incorrect (ignores memory warnings, keeping all cached images in memory):**

```swift
import UIKit

class ImageGalleryCache {
    private var cache: [String: UIImage] = [:]

    func store(image: UIImage, forKey key: String) {
        cache[key] = image
    }

    func image(forKey key: String) -> UIImage? {
        cache[key]
    }

    func preloadGallery(urls: [String]) {
        for url in urls {
            // Stores full-resolution images with no eviction policy
            let image = UIImage(systemName: "photo")!
            cache[url] = image
        }
    }

    var cachedCount: Int { cache.count }
    // No memory warning handling — Jetsam kills the app
}
```

**Proof Test (simulates memory warning, verifies cache is purged):**

```swift
import XCTest
import UIKit

final class ImageGalleryCacheMemoryTests: XCTestCase {
    func testCacheRespondsToMemoryWarning() {
        let cache = ImageGalleryCache()

        // Preload many images
        let urls = (0..<500).map { "https://example.com/img/\($0).jpg" }
        cache.preloadGallery(urls: urls)
        XCTAssertEqual(cache.cachedCount, 500)

        // Simulate memory warning
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        // Cache should be cleared to prevent Jetsam kill
        XCTAssertEqual(cache.cachedCount, 0,
            "Cache not cleared on memory warning — app will be killed by Jetsam")
    }
}
```

**Correct (subscribes to memory warning and purges cache to avoid termination):**

```swift
import UIKit

class ImageGalleryCache {
    private var cache: [String: UIImage] = [:]

    init() {
        // Subscribe to memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    func store(image: UIImage, forKey key: String) {
        cache[key] = image
    }

    func image(forKey key: String) -> UIImage? {
        cache[key]
    }

    func preloadGallery(urls: [String]) {
        for url in urls {
            let image = UIImage(systemName: "photo")!
            cache[url] = image
        }
    }

    @objc private func handleMemoryWarning() {
        cache.removeAll()  // shed memory to survive Jetsam
    }

    var cachedCount: Int { cache.count }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
```
