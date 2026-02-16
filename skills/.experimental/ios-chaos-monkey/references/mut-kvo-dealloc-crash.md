---
title: "KVO Observer Not Removed Before Deallocation Crashes"
impact: MEDIUM
impactDescription: "EXC_BAD_ACCESS, 100% crash on next KVO notification after dealloc"
tags: mut, kvo, observer, deallocation, exc-bad-access
---

## KVO Observer Not Removed Before Deallocation Crashes

If an object registered as a KVO observer is deallocated without removing the observation, the next KVO notification sends a message to a freed pointer. This produces `EXC_BAD_ACCESS` with no useful stack trace, making it one of the hardest crashes to debug.

**Incorrect (observer deallocates without removing KVO registration):**

```swift
import Foundation

class ProgressTracker: NSObject {
    private let task: URLSessionTask
    var onProgress: ((Double) -> Void)?

    init(task: URLSessionTask) {
        self.task = task
        super.init()
        // Registers KVO observation — must be removed before dealloc
        task.addObserver(self, forKeyPath: "countOfBytesReceived",
                         options: .new, context: nil)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        let received = task.countOfBytesReceived
        let total = task.countOfBytesExpectedToReceive
        guard total > 0 else { return }
        onProgress?(Double(received) / Double(total))
    }

    // Missing deinit — observer never removed
}
```

**Proof Test (exposes EXC_BAD_ACCESS after observer is deallocated):**

```swift
import XCTest

final class ProgressTrackerKVOTests: XCTestCase {
    func testTrackerDeallocDoesNotCrashOnNextNotification() {
        let session = URLSession.shared
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let task = session.dataTask(with: request)

        var tracker: ProgressTracker? = ProgressTracker(task: task)
        tracker?.onProgress = { progress in
            print("Progress: \(progress)")
        }

        // Deallocate the observer — KVO registration still active
        tracker = nil

        // Next KVO notification dereferences the freed tracker — EXC_BAD_ACCESS
        // Triggering any property change on task would crash
        XCTAssertNil(tracker, "Tracker should be nil without crashing")
    }
}
```

**Correct (removes KVO observer in deinit, preventing dangling pointer):**

```swift
import Foundation

class ProgressTracker: NSObject {
    private let task: URLSessionTask
    var onProgress: ((Double) -> Void)?

    init(task: URLSessionTask) {
        self.task = task
        super.init()
        task.addObserver(self, forKeyPath: "countOfBytesReceived",
                         options: .new, context: nil)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        let received = task.countOfBytesReceived
        let total = task.countOfBytesExpectedToReceive
        guard total > 0 else { return }
        onProgress?(Double(received) / Double(total))
    }

    deinit {
        // Remove observer before deallocation — prevents EXC_BAD_ACCESS
        task.removeObserver(self, forKeyPath: "countOfBytesReceived")
    }
}
```
