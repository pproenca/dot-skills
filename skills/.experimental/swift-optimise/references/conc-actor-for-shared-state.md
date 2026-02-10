---
title: Replace Lock-Based Shared State with Actors
impact: HIGH
impactDescription: compiler-enforced mutual exclusion eliminates data races that cause intermittent crashes in 1-5% of concurrent access patterns
tags: conc, actor, locks, thread-safety, shared-state
---

## Replace Lock-Based Shared State with Actors

Manual lock-based synchronization with `NSLock` or `DispatchQueue` is error-prone: every access to the protected state must be wrapped in the correct lock/unlock pair, and a single missed call introduces a data race. Actors provide compiler-enforced mutual exclusion -- all access to an actor's mutable state is automatically serialized, and the compiler rejects unsafe cross-isolation access at build time.

**Incorrect (manual lock management, easy to miss):**

```swift
class ImageCache {
    private let lock = NSLock()
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache[url]
    }

    func store(_ image: UIImage, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        cache[url] = image
    }

    func clearExpired(olderThan urls: Set<URL>) {
        // Forgetting to lock here causes a data race
        for url in urls {
            cache.removeValue(forKey: url)
        }
    }
}
```

**Correct (compiler-enforced mutual exclusion):**

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        cache[url]
    }

    func store(_ image: UIImage, for url: URL) {
        cache[url] = image
    }

    func clearExpired(olderThan urls: Set<URL>) {
        // Actor isolation guarantees exclusive access
        for url in urls {
            cache.removeValue(forKey: url)
        }
    }
}
```

Reference: [Actor](https://developer.apple.com/documentation/swift/actor)
