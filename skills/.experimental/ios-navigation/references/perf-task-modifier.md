---
title: Use .task for Async Data Loading on Navigation
impact: MEDIUM-HIGH
impactDescription: automatic cancellation on pop, zero main thread blocking
tags: perf, task, async, cancellation, lifecycle
---

## Use .task for Async Data Loading on Navigation

The `.task { }` modifier starts async work when the view appears and automatically cancels the underlying `Task` when the view disappears — for example, when the user pops back. This eliminates zombie network calls that waste bandwidth and CPU, prevents data races from responses arriving after the view is gone, and removes the need for manual cancellation bookkeeping.

**Incorrect (manual cancellation tracking in onAppear):**

```swift
struct OrderDetailView: View {
    @State private var viewModel = OrderDetailViewModel()
    let orderId: String
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            OrderContentView(order: viewModel.order)
        }
        .onAppear {
            // BAD: Starts work but does NOT auto-cancel on disappear.
            loadTask = Task {
                await viewModel.loadOrder(id: orderId)
            }
        }
        .onDisappear {
            // Easy to forget. If omitted, the network call
            // completes even though nobody is watching.
            loadTask?.cancel()
        }
    }
}
```

**Correct (automatic cancellation with .task):**

```swift
@Equatable
struct OrderDetailView: View {
    @State private var viewModel = OrderDetailViewModel()
    let orderId: String

    var body: some View {
        ScrollView {
            if let order = viewModel.order {
                OrderContentView(order: order)
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
        // .task auto-cancels when the view disappears (user pops back).
        // No manual Task tracking needed. SwiftUI manages the lifecycle.
        .task {
            await viewModel.loadOrder(id: orderId)
        }
    }
}

@Observable @MainActor
class OrderDetailViewModel {
    var order: Order?
    var isLoading = false

    func loadOrder(id: String) async {
        isLoading = true
        do {
            let order = try await APIClient.shared.fetchOrder(id: id)
            try Task.checkCancellation()
            self.order = order
            self.isLoading = false
        } catch is CancellationError {
            // User navigated away — silently discard.
        } catch {
            self.isLoading = false
        }
    }
}
```
