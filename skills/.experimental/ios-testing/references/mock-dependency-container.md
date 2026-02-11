---
title: "Use a Dependency Container for Test Configuration"
impact: MEDIUM
impactDescription: "single point of test dependency replacement"
tags: mock, container, dependency-injection, configuration
---

## Use a Dependency Container for Test Configuration

Manually injecting 5+ mocks into every test method creates verbose setup that obscures the test intent and must be updated everywhere when a new dependency is added. A dependency container centralizes all test doubles in a single configuration point, so each test only overrides the dependency it cares about.

**Incorrect (every test repeats all mock injection):**

```swift
func testPlaceOrder() async throws {
    let viewModel = OrderViewModel(
        paymentService: MockPaymentService(result: .success(.confirmed)),
        inventoryChecker: MockInventoryChecker(isAvailable: true),
        analytics: MockAnalytics(),
        notificationSender: MockNotificationSender(),
        logger: MockLogger() // 5 mocks repeated in every test — adding a 6th requires editing all tests
    )

    await viewModel.placeOrder(itemId: "SKU-200", quantity: 1)
    XCTAssertEqual(viewModel.state, .confirmed)
}
```

**Correct (container provides defaults, test overrides only what matters):**

```swift
struct TestDependencies: DependencyProviding {
    var paymentService: PaymentProcessing = MockPaymentService(result: .success(.confirmed))
    var inventoryChecker: InventoryChecking = MockInventoryChecker(isAvailable: true)
    var analytics: AnalyticsTracking = MockAnalytics()
    var notificationSender: NotificationSending = MockNotificationSender()
    var logger: Logging = MockLogger() // add new dependencies here once — all tests inherit the default
}

func testPlaceOrderWhenOutOfStock() async throws {
    var deps = TestDependencies()
    deps.inventoryChecker = MockInventoryChecker(isAvailable: false) // override only the relevant dependency
    let viewModel = OrderViewModel(dependencies: deps)

    await viewModel.placeOrder(itemId: "SKU-200", quantity: 1)
    XCTAssertEqual(viewModel.state, .outOfStock)
}
```
