---
title: Extract Use Cases as Protocols with Single Execute Method
impact: HIGH
impactDescription: enables independent testing of business logic — each use case testable in isolation
tags: layer, usecase, protocol, clean-architecture, testing
---

## Extract Use Cases as Protocols with Single Execute Method

Business logic buried in ViewModels or services creates god objects that are hard to test and reuse. Extract each distinct operation into a Use Case protocol with a single `execute` method. ViewModels compose multiple use cases. Each use case is independently testable with a mock repository.

**Incorrect (ViewModel contains all business logic — god object, hard to test):**

```swift
@Observable
class OrderViewModel {
    var orders: [Order] = []
    var filteredOrders: [Order] = []

    func loadOrders() async {
        let url = URL(string: "https://api.example.com/orders")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        orders = try! JSONDecoder().decode([Order].self, from: data)
    }

    func cancelOrder(_ order: Order) async {
        var request = URLRequest(url: URL(string: "https://api.example.com/orders/\(order.id)/cancel")!)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
        orders.removeAll { $0.id == order.id }
    }

    func filterOrders(by status: OrderStatus) {
        filteredOrders = orders.filter { $0.status == status }
    }
}
```

**Correct (use cases as protocols — composable, independently testable):**

```swift
// Domain layer — each use case is a protocol
protocol FetchOrdersUseCase {
    func execute() async throws -> [Order]
}

protocol CancelOrderUseCase {
    func execute(orderId: String) async throws
}

protocol FilterOrdersUseCase {
    func execute(orders: [Order], status: OrderStatus) -> [Order]
}

// Implementations depend on repository protocols
final class FetchOrdersUseCaseImpl: FetchOrdersUseCase {
    private let repository: OrderRepository

    init(repository: OrderRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Order] {
        try await repository.fetchAll()
    }
}

// ViewModel composes use cases — thin orchestration layer
@Observable
class OrderViewModel {
    var orders: [Order] = []
    var filteredOrders: [Order] = []

    private let fetchOrders: FetchOrdersUseCase
    private let cancelOrder: CancelOrderUseCase
    private let filterOrders: FilterOrdersUseCase

    init(
        fetchOrders: FetchOrdersUseCase,
        cancelOrder: CancelOrderUseCase,
        filterOrders: FilterOrdersUseCase
    ) {
        self.fetchOrders = fetchOrders
        self.cancelOrder = cancelOrder
        self.filterOrders = filterOrders
    }

    func load() async {
        orders = (try? await fetchOrders.execute()) ?? []
    }

    func cancel(_ order: Order) async {
        try? await cancelOrder.execute(orderId: order.id)
        orders.removeAll { $0.id == order.id }
    }

    func filter(by status: OrderStatus) {
        filteredOrders = filterOrders.execute(orders: orders, status: status)
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
