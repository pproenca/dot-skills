---
title: "Await Async Functions Directly in Tests"
impact: HIGH
impactDescription: "eliminates XCTestExpectation boilerplate entirely"
tags: async, await, swift-testing, boilerplate
---

## Await Async Functions Directly in Tests

Wrapping every async call in XCTestExpectation adds 4-6 lines of ceremony that obscure the actual assertion. Marking the test function as `async` lets you `await` the result directly, producing tests that read like synchronous code with zero timeout tuning.

**Incorrect (boilerplate hides the actual assertion):**

```swift
final class PaymentServiceTests: XCTestCase {
    func testChargeSucceeds() {
        let expectation = expectation(description: "charge completes")
        let service = PaymentService(gateway: MockGateway())

        Task {
            let result = try await service.charge(amount: 49_99, currency: .usd)
            XCTAssertEqual(result.status, .captured)
            expectation.fulfill() // easy to forget — test passes silently if omitted
        }

        wait(for: [expectation], timeout: 5.0) // arbitrary timeout masks slow or hanging tests
    }
}
```

**Correct (test reads like synchronous code):**

```swift
final class PaymentServiceTests: XCTestCase {
    func testChargeSucceeds() async throws {
        let service = PaymentService(gateway: MockGateway())

        let result = try await service.charge(amount: 49_99, currency: .usd) // no expectation, no timeout
        XCTAssertEqual(result.status, .captured)
    }
}
```
