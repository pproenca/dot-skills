---
title: Compose Dependency Container at App Root
impact: MEDIUM
impactDescription: centralizes all dependency wiring — single place to swap real/mock implementations
tags: di, container, composition, environment, app-root
---

## Compose Dependency Container at App Root

Dependencies scattered across view initializers create implicit coupling and make it impossible to swap implementations for testing. Compose all dependencies at the app root using `@Environment` injection. Each feature coordinator or view receives its dependencies from the environment, and the app root is the single place where real vs mock implementations are chosen.

**Incorrect (dependencies created inline — scattered, no central wiring):**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            // Dependencies created ad-hoc — no central control
            OrderListView(
                viewModel: OrderListViewModel(
                    fetchOrders: FetchOrdersUseCaseImpl(
                        repository: APIOrderRepository(session: .shared)
                    )
                )
            )
        }
    }
}
```

**Correct (dependency container composed at app root, injected via Environment):**

```swift
@Observable
final class AppDependencies {
    let orderRepository: OrderRepository
    let fetchOrders: FetchOrdersUseCase
    let cancelOrder: CancelOrderUseCase

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
        self.fetchOrders = FetchOrdersUseCaseImpl(repository: orderRepository)
        self.cancelOrder = CancelOrderUseCaseImpl(repository: orderRepository)
    }

    static let live = AppDependencies(
        orderRepository: APIOrderRepository(session: .shared)
    )

    static let mock = AppDependencies(
        orderRepository: MockOrderRepository()
    )
}

@main
struct MyApp: App {
    @State private var dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            OrderFlowView()
                .environment(dependencies)
        }
    }
}

// Feature views read dependencies from environment
struct OrderFlowView: View {
    @Environment(AppDependencies.self) private var deps
    @State private var coordinator = OrderCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderListView(
                viewModel: OrderListViewModel(fetchOrders: deps.fetchOrders)
            )
        }
        .environment(coordinator)
    }
}

// Previews use mock container
#Preview {
    OrderFlowView()
        .environment(AppDependencies.mock)
}
```

Reference: [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey)
