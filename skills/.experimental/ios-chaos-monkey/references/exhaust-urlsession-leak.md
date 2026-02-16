---
title: "URLSession Not Invalidated Leaks Delegate and Connections"
impact: MEDIUM
impactDescription: "each leaked session retains delegate + open connections permanently"
tags: exhaust, urlsession, leak, delegate, invalidation
---

## URLSession Not Invalidated Leaks Delegate and Connections

`URLSession` retains its delegate strongly. Without calling `invalidateAndCancel()` or `finishTasksAndInvalidate()`, both the session and its delegate are never deallocated. Creating a session per request leaks memory linearly, eventually exhausting the app's allocation.

**Incorrect (creates a new session per request, leaking delegate each time):**

```swift
import Foundation

class NetworkManager: NSObject, URLSessionDataDelegate {
    var completionHandler: ((Data?) -> Void)?

    func fetch(url: URL, completion: @escaping (Data?) -> Void) {
        completionHandler = completion
        let config = URLSessionConfiguration.default
        // New session per request — retains self as delegate forever
        let session = URLSession(configuration: config,
                                 delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url)
        task.resume()
        // Session never invalidated — self is leaked
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        completionHandler?(nil)
    }

    deinit {
        print("NetworkManager deallocated")
    }
}
```

**Proof Test (exposes the delegate leak by verifying deallocation):**

```swift
import XCTest

final class NetworkManagerLeakTests: XCTestCase {
    func testNetworkManagerDeallocatesAfterRequest() async throws {
        weak var weakManager: NetworkManager?

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            let manager = NetworkManager()
            weakManager = manager
            let url = URL(string: "https://example.com")!

            manager.fetch(url: url) { _ in
                continuation.resume()
            }
        }

        // Give time for deallocation
        try await Task.sleep(for: .seconds(1))

        // weakManager should be nil if properly deallocated
        XCTAssertNil(weakManager,
            "NetworkManager was not deallocated — URLSession retains delegate")
    }
}
```

**Correct (invalidates session after use, releasing delegate reference):**

```swift
import Foundation

class NetworkManager: NSObject, URLSessionDataDelegate {
    private var session: URLSession?
    var completionHandler: ((Data?) -> Void)?

    func fetch(url: URL, completion: @escaping (Data?) -> Void) {
        completionHandler = completion
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config,
                                 delegate: self, delegateQueue: nil)
        self.session = session
        let task = session.dataTask(with: url)
        task.resume()
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        completionHandler?(nil)
        // Invalidate releases the delegate reference
        session.finishTasksAndInvalidate()
        self.session = nil
    }

    deinit {
        print("NetworkManager deallocated")
    }
}
```
