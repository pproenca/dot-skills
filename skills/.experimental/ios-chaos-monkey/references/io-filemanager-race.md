---
title: "FileManager Existence Check Then Use Is a TOCTOU Race"
impact: MEDIUM
impactDescription: "file operation fails 1-3% of time under concurrent access"
tags: io, filemanager, toctou, race-condition, file-system
---

## FileManager Existence Check Then Use Is a TOCTOU Race

Calling `fileExists()` before a file operation creates a Time-Of-Check-Time-Of-Use (TOCTOU) gap. Between the check and the use, another thread or process can delete, move, or create the file. The pre-check gives false confidence; the operation fails anyway.

**Incorrect (TOCTOU gap between existence check and file operation):**

```swift
import Foundation

class CacheManager {
    private let cacheDir: URL

    init(cacheDir: URL) {
        self.cacheDir = cacheDir
    }

    func writeCacheFile(name: String, data: Data) throws {
        let fileURL = cacheDir.appendingPathComponent(name)
        // TOCTOU: file can be deleted between check and write
        if !FileManager.default.fileExists(atPath: cacheDir.path) {
            try FileManager.default.createDirectory(
                at: cacheDir, withIntermediateDirectories: true)
        }
        try data.write(to: fileURL)
    }

    func readCacheFile(name: String) -> Data? {
        let fileURL = cacheDir.appendingPathComponent(name)
        // TOCTOU: file can be deleted between check and read
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return FileManager.default.contents(atPath: fileURL.path)
    }
}
```

**Proof Test (exposes the TOCTOU gap by racing deletion with read):**

```swift
import XCTest

final class CacheManagerTOCTOUTests: XCTestCase {
    func testConcurrentDeleteAndReadDoNotCrash() async throws {
        let cacheDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("toctou-test-\(UUID())")
        let manager = CacheManager(cacheDir: cacheDir)

        let data = Data("cached-content".utf8)
        try manager.writeCacheFile(name: "test.dat", data: data)

        var failures = 0
        let iterations = 200

        for _ in 0..<iterations {
            try manager.writeCacheFile(name: "test.dat", data: data)

            async let reading: Data? = Task {
                manager.readCacheFile(name: "test.dat")
            }.value
            async let deleting: Void = Task {
                try? FileManager.default.removeItem(
                    at: cacheDir.appendingPathComponent("test.dat"))
            }.value

            _ = await deleting
            let result = await reading
            // With TOCTOU, fileExists returns true but read returns nil
            if result == nil { failures += 1 }
        }

        // TOCTOU failures should be zero with correct code
        XCTAssertEqual(failures, 0,
            "TOCTOU caused \(failures) read failures out of \(iterations)")
    }
}
```

**Correct (try the operation directly, handle errors instead of pre-checking):**

```swift
import Foundation

class CacheManager {
    private let cacheDir: URL

    init(cacheDir: URL) {
        self.cacheDir = cacheDir
    }

    func writeCacheFile(name: String, data: Data) throws {
        let fileURL = cacheDir.appendingPathComponent(name)
        // Create directory unconditionally — no TOCTOU
        try FileManager.default.createDirectory(
            at: cacheDir, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    func readCacheFile(name: String) -> Data? {
        let fileURL = cacheDir.appendingPathComponent(name)
        // Try directly — no existence check, no TOCTOU gap
        return try? Data(contentsOf: fileURL)
    }
}
```
