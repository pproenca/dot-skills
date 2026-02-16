---
title: "Task Captures Self Extending Lifetime Beyond Expected Scope"
impact: MEDIUM-HIGH
impactDescription: "ViewModel survives screen dismissal, processes stale data"
tags: mem, task, async, self-capture, structured-concurrency
---

## Task Captures Self Extending Lifetime Beyond Expected Scope

`Task { self.fetchData() }` implicitly captures `self` strongly. If the Task performs a long-running operation (network call, pagination), it keeps the ViewModel alive well after the user has left the screen. The ViewModel processes stale data, updates phantom UI state, and is only freed when the task finally completes.

**Incorrect (ViewModel survives screen dismissal during long fetch):**

```swift
import Observation

@Observable
final class OrderListViewModel {
    var orders: [Order] = []
    var isLoading = false
    private let orderService: OrderService

    init(orderService: OrderService) {
        self.orderService = orderService
    }

    func loadOrders() {
        isLoading = true
        Task {
            let fetched = try await orderService.fetchAllOrders() // 5-10s network call
            self.orders = fetched // strong self — ViewModel alive until task finishes
            self.isLoading = false
        }
    }

    deinit { print("OrderListViewModel deallocated") }
}
```

**Proof Test (exposes extended lifetime — ViewModel not freed after scope exits):**

```swift
import XCTest
@testable import MyApp

final class AsyncTaskSelfCaptureTests: XCTestCase {

    func testViewModelDeallocatesAfterScreenDismissal() async throws {
        weak var weakVM: OrderListViewModel?
        let service = SlowOrderService() // returns after 2 seconds

        autoreleasepool {
            let vm = OrderListViewModel(orderService: service)
            weakVM = vm
            vm.loadOrders()
            // Screen dismissed — all strong references dropped
        }

        // Give task time to still be in-flight
        try await Task.sleep(for: .milliseconds(100))

        // ViewModel still alive — Task holds strong reference
        XCTAssertNil(weakVM, "OrderListViewModel leaked — Task extended its lifetime")
    }
}
```

**Correct (weak self in Task, cancelled via structured concurrency):**

```swift
import Observation

@Observable
final class OrderListViewModel {
    var orders: [Order] = []
    var isLoading = false
    private let orderService: OrderService
    private var loadTask: Task<Void, Never>?

    init(orderService: OrderService) {
        self.orderService = orderService
    }

    func loadOrders() {
        isLoading = true
        loadTask = Task { [weak self] in // weak self — ViewModel can deallocate freely
            guard let self else { return }
            do {
                let fetched = try await orderService.fetchAllOrders()
                guard !Task.isCancelled else { return } // respect cancellation
                self.orders = fetched
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }

    deinit {
        loadTask?.cancel() // deterministic cleanup on deallocation
        print("OrderListViewModel deallocated")
    }
}
```
