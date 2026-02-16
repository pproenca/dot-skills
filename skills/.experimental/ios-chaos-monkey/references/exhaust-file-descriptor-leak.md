---
title: "File Handle Not Closed Leaks File Descriptors"
impact: LOW-MEDIUM
impactDescription: "EMFILE error after ~256 leaked descriptors, all I/O fails"
tags: exhaust, file-descriptor, leak, file-handle, resource
---

## File Handle Not Closed Leaks File Descriptors

Opening `FileHandle` for reading or writing without closing it leaks the underlying file descriptor. Each process has a limited number of descriptors (~256 on iOS). After exhaustion, every file open, socket connect, and database query fails with `EMFILE — too many open files`.

**Incorrect (opens file handles without closing, leaking descriptors):**

```swift
import Foundation

class LogRotator {
    private let logDirectory: URL

    init(logDirectory: URL) {
        self.logDirectory = logDirectory
    }

    func readAllLogs() -> [String] {
        var contents: [String] = []
        let files = (try? FileManager.default.contentsOfDirectory(
            at: logDirectory, includingPropertiesForKeys: nil)) ?? []

        for file in files {
            // FileHandle opened but never closed — descriptor leaks
            let handle = FileHandle(forReadingAtPath: file.path)
            if let data = handle?.readDataToEndOfFile() {
                if let text = String(data: data, encoding: .utf8) {
                    contents.append(text)
                }
            }
            // Missing: handle?.closeFile()
        }
        return contents
    }

    func appendToLog(name: String, message: String) {
        let url = logDirectory.appendingPathComponent(name)
        let handle = FileHandle(forWritingAtPath: url.path)
        handle?.seekToEndOfFile()
        handle?.write(Data(message.utf8))
        // Missing: handle?.closeFile()
    }
}
```

**Proof Test (exposes descriptor exhaustion after repeated opens without close):**

```swift
import XCTest

final class LogRotatorDescriptorTests: XCTestCase {
    func testRepeatedReadsDoNotLeakDescriptors() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("logs-\(UUID())")
        try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true)

        // Create test log files
        for i in 0..<300 {
            let url = dir.appendingPathComponent("log-\(i).txt")
            try Data("entry \(i)".utf8).write(to: url)
        }

        let rotator = LogRotator(logDirectory: dir)

        // Read all logs multiple times — leaks descriptors each pass
        for _ in 0..<3 {
            let logs = rotator.readAllLogs()
            XCTAssertEqual(logs.count, 300)
        }

        // After ~256 leaked descriptors, this open fails
        let testFile = dir.appendingPathComponent("canary.txt")
        try Data("test".utf8).write(to: testFile)
        let canary = FileHandle(forReadingAtPath: testFile.path)
        XCTAssertNotNil(canary,
            "Cannot open file — descriptor exhaustion from leaked handles")
        canary?.closeFile()
    }
}
```

**Correct (closes file handle with defer, preventing descriptor leaks):**

```swift
import Foundation

class LogRotator {
    private let logDirectory: URL

    init(logDirectory: URL) {
        self.logDirectory = logDirectory
    }

    func readAllLogs() -> [String] {
        var contents: [String] = []
        let files = (try? FileManager.default.contentsOfDirectory(
            at: logDirectory, includingPropertiesForKeys: nil)) ?? []

        for file in files {
            guard let handle = FileHandle(forReadingAtPath: file.path) else {
                continue
            }
            defer { handle.closeFile() }  // always closes, even on error
            let data = handle.readDataToEndOfFile()
            if let text = String(data: data, encoding: .utf8) {
                contents.append(text)
            }
        }
        return contents
    }

    func appendToLog(name: String, message: String) {
        let url = logDirectory.appendingPathComponent(name)
        guard let handle = FileHandle(forWritingAtPath: url.path) else {
            return
        }
        defer { handle.closeFile() }
        handle.seekToEndOfFile()
        handle.write(Data(message.utf8))
    }
}
```
