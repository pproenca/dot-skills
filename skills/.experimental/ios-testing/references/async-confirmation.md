---
title: "Use confirmation() for Callback-Based APIs"
impact: HIGH
impactDescription: "type-safe callback verification with automatic timeout"
tags: async, confirmation, callbacks, swift-testing
---

## Use confirmation() for Callback-Based APIs

XCTestExpectation is stringly-typed and fails silently if `fulfill()` is never called within the timeout. Swift Testing's `confirmation()` provides a scoped, type-safe block that automatically fails when the expected callback count is not met, eliminating an entire class of false-positive tests.

**Incorrect (stringly-typed expectation can silently pass):**

```swift
final class NotificationServiceTests: XCTestCase {
    func testObserverReceivesUpdate() {
        let expectation = expectation(description: "observer notified")
        let service = NotificationService()

        service.onUpdate = { payload in
            XCTAssertEqual(payload.channel, "orders")
            expectation.fulfill()
        }

        service.broadcast(channel: "orders", message: "new order")
        wait(for: [expectation], timeout: 2.0) // silently passes if onUpdate is never assigned
    }
}
```

**Correct (compiler-enforced callback verification):**

```swift
struct NotificationServiceTests {
    @Test func observerReceivesUpdate() async {
        let service = NotificationService()

        await confirmation { confirm in // fails automatically if confirm is never called
            service.onUpdate = { payload in
                #expect(payload.channel == "orders")
                confirm()
            }

            service.broadcast(channel: "orders", message: "new order")
        }
    }
}
```
