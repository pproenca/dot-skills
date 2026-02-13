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
    @StateObject private var viewModel = OrderDetailViewModel()
    let orderId: String

    // BAD: Manual task tracking is error-prone and verbose.
    // If the user pops back quickly, the response may arrive
    // after the view is deallocated — causing a state update
    // on a freed object or a wasted decode cycle.
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            OrderContentView(order: viewModel.order)
        }
        .onAppear {
            // Starts work but does NOT auto-cancel on disappear.
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

class OrderDetailViewModel: ObservableObject {
    @Published var order: Order?

    func loadOrder(id: String) async {
        // No cancellation check — runs to completion even if cancelled.
        let result = try? await APIClient.shared.fetchOrder(id: id)
        await MainActor.run { self.order = result }
    }
}
```

**Correct (automatic cancellation with .task):**

```swift
struct OrderDetailView: View {
    @StateObject private var viewModel = OrderDetailViewModel()
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

class OrderDetailViewModel: ObservableObject {
    @Published var order: Order?
    @Published var isLoading = false

    func loadOrder(id: String) async {
        await MainActor.run { isLoading = true }

        do {
            // If the task is cancelled (user popped back),
            // URLSession throws CancellationError — no wasted work.
            let order = try await APIClient.shared.fetchOrder(id: id)

            // Check cancellation before updating state, in case
            // cancellation happened between response and this line.
            try Task.checkCancellation()

            await MainActor.run {
                self.order = order
                self.isLoading = false
            }
        } catch is CancellationError {
            // User navigated away — silently discard. No state update.
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
```
