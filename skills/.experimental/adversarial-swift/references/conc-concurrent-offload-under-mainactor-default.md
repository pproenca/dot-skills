---
title: Mark CPU-bound async work @concurrent under MainActor default isolation
tags: conc, mainactor, concurrent-attribute, performance
---

## Mark CPU-bound async work @concurrent under MainActor default isolation

In a target built with Default Actor Isolation = MainActor (the Xcode 26 default for app targets), the wrong default is writing CPU-bound async helpers — image resizing, parsing, hashing — with no isolation annotation, so they inherit `@MainActor` and run the heavy work on the main thread. The code compiles and returns correct results while blocking the main actor: UI hitches and dropped frames with no error anywhere pointing at the cause. `@concurrent` (Swift 6.2) moves the function to the concurrent thread pool; `nonisolated` is the accepted alternative.

**Evidence of violation:** with stack facts declaring MainActor default isolation, an `async` function whose body is CPU-bound (tight loops over data, large encode/decode, image transforms) that carries neither `@concurrent` nor `nonisolated`. A CPU-bound function that reads or writes main-actor state also fails — it cannot be `@concurrent` as written and needs the compute split from the state access. PASS: CPU-bound async functions are marked `@concurrent` or `nonisolated`, or the heavy work runs inside a task group or detached task off the main actor. N/A: the stack facts do not declare MainActor default isolation (projects on toolchains older than Swift 6.2 cannot enable it, so they are N/A by construction), or the target contains no CPU-bound async functions.

**Incorrect (resize inherits @MainActor from the target default — the heavy work blocks the main thread):**

```swift
import Foundation
import CoreGraphics

// In a target that uses Default Actor Isolation: MainActor

class PhotoManager {
    func updateThumbnail(
        with imageData: Data
    ) async {
        let resized = await resize(
            imageData,
            to: CGSize(width: 120, height: 120)
        )

        // update UI
        _ = resized
    }

    func resize(
        _ imageData: Data,
        to size: CGSize
    ) async -> Data {
        // Tight per-byte loop — runs on the main actor
        var downsampled = Data(capacity: imageData.count / 4)
        for (offset, byte) in imageData.enumerated() where offset % 4 == 0 {
            downsampled.append(byte)
        }
        return downsampled
    }
}
```

**Correct (@concurrent moves the resize onto the concurrent thread pool):**

```swift
import Foundation
import CoreGraphics

// In a target that uses Default Actor Isolation: MainActor

class PhotoManager {
    func updateThumbnail(
        with imageData: Data
    ) async {
        let resized = await resize(
            imageData,
            to: CGSize(width: 120, height: 120)
        )

        // update UI
        _ = resized
    }

    @concurrent
    func resize(
        _ imageData: Data,
        to size: CGSize
    ) async -> Data {
        // Same tight loop — now off the main actor
        var downsampled = Data(capacity: imageData.count / 4)
        for (offset, byte) in imageData.enumerated() where offset % 4 == 0 {
            downsampled.append(byte)
        }
        return downsampled
    }
}
```
