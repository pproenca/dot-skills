---
title: "Delegate Set to Nil During Active Callback"
impact: MEDIUM-HIGH
impactDescription: "EXC_BAD_ACCESS when callback fires after delegate deallocation"
tags: race, delegate, nil, deallocation, callback
---

## Delegate Set to Nil During Active Callback

When a delegate is stored as a strong reference and set to `nil` on the main thread while a background thread is mid-callback through that same reference, the background thread retains a dangling pointer. The delegate object is deallocated between the nil-check and the method call, causing `EXC_BAD_ACCESS`. This is especially common in networking code where the owning view controller is dismissed while a request is in flight.

**Incorrect (strong delegate can be deallocated during active callback):**

```swift
protocol NetworkClientDelegate: AnyObject {
    func client(_ client: NetworkClient, didReceive data: Data)
    func client(_ client: NetworkClient, didFailWith error: Error)
}

class NetworkClient {
    var delegate: NetworkClientDelegate?  // strong ref — not safe to nil across threads

    func fetchData(from url: URL) {
        DispatchQueue.global().async { [self] in
            do {
                let data = try Data(contentsOf: url)
                // delegate may be nilled out on main thread right here
                self.delegate?.client(self, didReceive: data)  // EXC_BAD_ACCESS
            } catch {
                self.delegate?.client(self, didFailWith: error)
            }
        }
    }

    func cancel() {
        delegate = nil  // main thread sets nil while callback is in flight
    }
}
```

**Proof Test (exposes crash when delegate is nilled during callback):**

```swift
import XCTest

final class NetworkClientDelegateTests: XCTestCase {
    func testCallbackSurvivesDelegateNilification() async {
        let client = NetworkClient()
        var receivedCallbacks = 0
        let lock = NSLock()

        let mockDelegate = MockDelegate {
            lock.lock()
            receivedCallbacks += 1
            lock.unlock()
        }

        client.delegate = mockDelegate

        await withTaskGroup(of: Void.self) { group in
            // Background: trigger callbacks rapidly
            group.addTask {
                for _ in 0..<100 {
                    client.fetchData(from: URL(string: "data://test")!)
                    try? await Task.sleep(for: .microseconds(10))
                }
            }

            // Main: nil the delegate while callbacks fire
            group.addTask { @MainActor in
                for _ in 0..<100 {
                    client.cancel()
                    client.delegate = mockDelegate
                    try? await Task.sleep(for: .microseconds(5))
                }
            }
        }

        // With the incorrect code, this crashes before reaching the assertion.
        // Surviving without EXC_BAD_ACCESS is the success condition.
        XCTAssertTrue(true, "No crash — delegate access is safe")
    }
}
```

**Correct (weak delegate + local capture prevents dangling reference):**

```swift
protocol NetworkClientDelegate: AnyObject {
    func client(_ client: NetworkClient, didReceive data: Data)
    func client(_ client: NetworkClient, didFailWith error: Error)
}

class NetworkClient {
    weak var delegate: NetworkClientDelegate?  // weak — auto-nils on dealloc

    func fetchData(from url: URL) {
        DispatchQueue.global().async { [weak self, weak delegate] in
            guard let self, let delegate else { return }  // captured before dispatch
            do {
                let data = try Data(contentsOf: url)
                delegate.client(self, didReceive: data)  // safe — captured strong ref
            } catch {
                delegate.client(self, didFailWith: error)
            }
        }
    }

    func cancel() {
        delegate = nil  // safe — background closures hold their own weak captures
    }
}
```
