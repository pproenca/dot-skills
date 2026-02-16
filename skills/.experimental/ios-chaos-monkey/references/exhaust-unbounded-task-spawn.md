---
title: "Unbounded Task Spawning in Loop Exhausts Memory"
impact: MEDIUM
impactDescription: "thousands of concurrent tasks consume 200MB+ memory"
tags: exhaust, task, concurrency, memory, task-group
---

## Unbounded Task Spawning in Loop Exhausts Memory

Spawning a `Task` per item in a large collection creates thousands of concurrent tasks simultaneously. Each task allocates its own stack and continuation, and without backpressure the memory footprint climbs past 200MB. iOS terminates the app with no crash log.

**Incorrect (spawns one task per item with no concurrency limit):**

```swift
import UIKit

class ThumbnailGenerator {
    private let cache = NSCache<NSString, UIImage>()

    func generateAll(for urls: [URL]) async -> [URL: UIImage] {
        var results: [URL: UIImage] = [:]

        await withTaskGroup(of: (URL, UIImage?).self) { group in
            for url in urls {
                group.addTask {
                    // All 10,000 tasks launch simultaneously
                    let image = await self.downloadAndResize(url)
                    return (url, image)
                }
            }
            for await (url, image) in group {
                if let image { results[url] = image }
            }
        }
        return results
    }

    private func downloadAndResize(_ url: URL) async -> UIImage? {
        try? await Task.sleep(for: .milliseconds(50))
        return UIImage()
    }
}
```

**Proof Test (exposes memory spike from unbounded task creation):**

```swift
import XCTest

final class ThumbnailGeneratorMemoryTests: XCTestCase {
    func testBulkGenerationDoesNotExhaustMemory() async {
        let generator = ThumbnailGenerator()
        let urls = (0..<10_000).map {
            URL(string: "https://example.com/img/\($0).jpg")!
        }

        let beforeMB = memoryUsageMB()
        _ = await generator.generateAll(for: urls)
        let afterMB = memoryUsageMB()

        let spikeMB = afterMB - beforeMB
        // Unbounded spawning creates 200MB+ spike
        XCTAssertLessThan(spikeMB, 50.0,
            "Memory spiked by \(spikeMB)MB — unbounded task spawning")
    }

    private func memoryUsageMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0, &count)
            }
        }
        return result == KERN_SUCCESS
            ? Double(info.resident_size) / 1_048_576.0
            : 0
    }
}
```

**Correct (limits concurrency with batched task group processing):**

```swift
import UIKit

class ThumbnailGenerator {
    private let cache = NSCache<NSString, UIImage>()
    private let maxConcurrency = 8

    func generateAll(for urls: [URL]) async -> [URL: UIImage] {
        var results: [URL: UIImage] = [:]

        await withTaskGroup(of: (URL, UIImage?).self) { group in
            var iterator = urls.makeIterator()

            // Seed the group with limited concurrent tasks
            for _ in 0..<maxConcurrency {
                guard let url = iterator.next() else { break }
                group.addTask { (url, await self.downloadAndResize(url)) }
            }

            // As each completes, add the next — constant backpressure
            for await (url, image) in group {
                if let image { results[url] = image }
                if let nextURL = iterator.next() {
                    group.addTask {
                        (nextURL, await self.downloadAndResize(nextURL))
                    }
                }
            }
        }
        return results
    }

    private func downloadAndResize(_ url: URL) async -> UIImage? {
        try? await Task.sleep(for: .milliseconds(50))
        return UIImage()
    }
}
```
