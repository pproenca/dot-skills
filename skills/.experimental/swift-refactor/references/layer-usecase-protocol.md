---
title: Remove Use-Case/Interactor Layers That Add Ceremony
impact: HIGH
impactDescription: cuts indirection and keeps refactors aligned with modular MVVM-C
tags: layer, architecture, repository, refactor, testing
---

## Remove Use-Case/Interactor Layers That Add Ceremony

When refactoring toward the clinic architecture, collapse single-purpose use-case wrappers into repository-backed ViewModel logic. Keep protocol boundaries at repository/coordinator/error-routing interfaces in Domain.

**Incorrect (one-line use-case wrappers):**

```swift
protocol FetchOrdersUseCase {
    func execute() async throws -> [Order]
}

final class FetchOrdersUseCaseImpl: FetchOrdersUseCase {
    private let repository: OrderRepository

    init(repository: OrderRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Order] {
        try await repository.fetchAll()
    }
}
```

**Correct (ViewModel uses repository protocol directly):**

```swift
protocol OrderRepository: Sendable {
    func fetchAll() async throws -> [Order]
    func cancel(orderID: String) async throws
}

@Observable
final class OrderViewModel {
    private let repository: any OrderRepository

    var orders: [Order] = []

    init(repository: any OrderRepository) {
        self.repository = repository
    }

    func load() async {
        orders = (try? await repository.fetchAll()) ?? []
    }

    func cancel(_ order: Order) async {
        do {
            try await repository.cancel(orderID: order.id)
            orders.removeAll { $0.id == order.id }
        } catch {
            // Route through ErrorRouting / AppError policy.
        }
    }
}
```

Only keep a dedicated use-case abstraction when the same cross-feature workflow is reused in multiple modules.
