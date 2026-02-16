---
title: "Concurrent File Writes Corrupt Data Without Coordination"
impact: MEDIUM-HIGH
impactDescription: "data corruption on 5-15% of concurrent writes, silent data loss"
tags: io, file-write, concurrency, data-corruption, dispatch-queue
---

## Concurrent File Writes Corrupt Data Without Coordination

Two threads writing to the same file simultaneously produce interleaved or truncated output. The OS does not serialize writes to the same path — one thread's write can overwrite another's mid-byte, corrupting the log permanently.

**Incorrect (interleaves writes from concurrent callers, corrupting file content):**

```swift
import Foundation

class LogFileWriter {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }

    func append(_ message: String) {
        let handle = try! FileHandle(forWritingTo: fileURL)
        handle.seekToEndOfFile()
        let data = Data("\(message)\n".utf8)
        handle.write(data)  // concurrent calls interleave bytes here
        handle.closeFile()
    }

    func readAll() -> String {
        (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
    }
}
```

**Proof Test (exposes corrupted output from 100 concurrent writes):**

```swift
import XCTest

final class LogFileWriterConcurrencyTests: XCTestCase {
    func testConcurrentWritesProduceCompleteLines() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-\(UUID()).log")
        let writer = LogFileWriter(fileURL: url)
        let lineCount = 100

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<lineCount {
                group.addTask {
                    writer.append("line-\(i)")  // races here
                }
            }
        }

        let contents = writer.readAll()
        let lines = contents.split(separator: "\n")
        // Corrupted writes produce fewer valid lines or merged text
        XCTAssertEqual(lines.count, lineCount,
            "Expected \(lineCount) lines but got \(lines.count) — data corrupted")
    }
}
```

**Correct (serial queue coordinates all writes, eliminating interleaving):**

```swift
import Foundation

class LogFileWriter {
    private let fileURL: URL
    private let writeQueue = DispatchQueue(label: "com.app.logwriter")

    init(fileURL: URL) {
        self.fileURL = fileURL
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }

    func append(_ message: String) {
        writeQueue.sync {  // serializes all file access
            let handle = try! FileHandle(forWritingTo: fileURL)
            handle.seekToEndOfFile()
            let data = Data("\(message)\n".utf8)
            handle.write(data)
            handle.closeFile()
        }
    }

    func readAll() -> String {
        writeQueue.sync {
            (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        }
    }
}
```
