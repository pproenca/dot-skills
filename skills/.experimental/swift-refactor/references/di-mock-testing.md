---
title: Add Mock Implementation for Every Protocol Dependency
impact: MEDIUM
impactDescription: enables isolated unit testing — verify ViewModel logic without real services
tags: di, mock, testing, protocol, isolation
---

## Add Mock Implementation for Every Protocol Dependency

Protocol dependencies without mock implementations cannot be tested in isolation. For every repository or use case protocol, create a corresponding mock that captures method calls and returns stubbed data. This enables testing ViewModel logic, use case composition, and error handling without real network calls, databases, or simulators.

**Incorrect (no mocks — ViewModel untestable without real API):**

```swift
protocol OrderRepository: Sendable {
    func fetchAll() async throws -> [Order]
    func cancel(orderId: String) async throws
}

// Only implementation is the real API client
final class APIOrderRepository: OrderRepository {
    func fetchAll() async throws -> [Order] {
        // Real network call
    }

    func cancel(orderId: String) async throws {
        // Real network call
    }
}

// Cannot test OrderViewModel without hitting the API
```

**Correct (mock captures calls, stubs return values, verifies interactions):**

```swift
protocol OrderRepository: Sendable {
    func fetchAll() async throws -> [Order]
    func cancel(orderId: String) async throws
}

final class MockOrderRepository: OrderRepository {
    var stubbedOrders: [Order] = []
    var stubbedError: Error?
    var cancelledOrderIds: [String] = []

    func fetchAll() async throws -> [Order] {
        if let error = stubbedError { throw error }
        return stubbedOrders
    }

    func cancel(orderId: String) async throws {
        if let error = stubbedError { throw error }
        cancelledOrderIds.append(orderId)
    }
}

// Test ViewModel in complete isolation
@Test
func loadOrders_displaysOrders() async {
    let mock = MockOrderRepository()
    mock.stubbedOrders = [
        Order(id: "1", title: "Widget", status: .pending)
    ]
    let useCase = FetchOrdersUseCaseImpl(repository: mock)
    let viewModel = OrderListViewModel(fetchOrders: useCase)

    await viewModel.load()

    #expect(viewModel.orders.count == 1)
    #expect(viewModel.orders.first?.title == "Widget")
}

@Test
func loadOrders_handlesError() async {
    let mock = MockOrderRepository()
    mock.stubbedError = URLError(.notConnectedToInternet)
    let useCase = FetchOrdersUseCaseImpl(repository: mock)
    let viewModel = OrderListViewModel(fetchOrders: useCase)

    await viewModel.load()

    #expect(viewModel.orders.isEmpty)
    #expect(viewModel.errorMessage != nil)
}
```

Reference: [Testing in Xcode](https://developer.apple.com/documentation/xctest)
