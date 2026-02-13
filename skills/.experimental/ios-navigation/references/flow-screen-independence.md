---
title: Keep Screens Independent of Parent Navigation Context
impact: MEDIUM
impactDescription: enables reuse across push, sheet, and deep link contexts
tags: flow, reusability, decoupling, screen-independence
---

## Keep Screens Independent of Parent Navigation Context

Individual screens should not know how they were presented -- whether pushed onto a stack, shown as a sheet, or launched via deep link. When a screen reads NavigationPath or checks its presentation context, it becomes tightly coupled to one navigation style and cannot be reused elsewhere. Passing data via initializer parameters and using `@Environment(\.dismiss)` for dismissal keeps screens portable across any presentation context.

**Incorrect (screen coupled to its navigation context):**

```swift
// BAD: Screen inspects how it was presented — breaks reuse in
// different navigation contexts and ties view to parent structure
struct OrderDetailView: View {
    // Directly reading the navigation path couples this view to
    // being inside a specific NavigationStack
    @Environment(NavigationCoordinator.self) private var coordinator
    @Environment(\.isPresented) private var isPresented

    let orderId: String

    var body: some View {
        VStack {
            Text("Order \(orderId)")

            Button("Done") {
                // Context-aware dismissal — this logic must be
                // updated every time the view is used differently
                if isPresented {
                    // Assume we're in a sheet
                    dismiss()
                } else {
                    // Assume we're in a navigation stack
                    coordinator.path.removeLast()
                }
            }
        }
        .onAppear {
            // Reading path count to determine behavior —
            // fragile assumption about stack depth
            if coordinator.path.count > 3 {
                // Show abbreviated view when "deep" in navigation
            }
        }
    }
}
```

**Correct (screen receives data via init, dismisses generically):**

```swift
// GOOD: Screen takes all data through its initializer and uses
// @Environment(\.dismiss) — works in push, sheet, or deep link
struct OrderDetailView: View {
    // Generic dismiss action works regardless of presentation:
    // pops from stack, dismisses sheet, or closes full-screen cover
    @Environment(\.dismiss) private var dismiss

    // All data passed via init — no assumptions about navigation
    let order: Order
    let onAction: ((OrderAction) -> Void)?

    // Default closure keeps the view usable in previews and tests
    init(order: Order, onAction: ((OrderAction) -> Void)? = nil) {
        self.order = order
        self.onAction = onAction
    }

    var body: some View {
        ScrollView {
            OrderHeaderView(order: order)
            OrderItemsListView(items: order.items)

            Button("Reorder") {
                // Delegate action to parent — screen doesn't need
                // to know if this triggers a push, sheet, or alert
                onAction?(.reorder(order))
            }

            Button("Done") {
                // Works in any context: pop, dismiss sheet, etc.
                dismiss()
            }
        }
        .navigationTitle("Order #\(order.number)")
    }
}

// The screen can now be used in any presentation context
// without modification:

// In a NavigationStack
NavigationLink(value: AppRoute.orderDetail(order)) {
    Text(order.number)
}

// As a sheet
.sheet(item: $selectedOrder) { order in
    NavigationStack {
        OrderDetailView(order: order)
    }
}

// From a deep link
func handleDeepLink(_ url: URL) {
    if let order = parseOrder(from: url) {
        // Same view, different context — no changes needed
        coordinator.path.append(AppRoute.orderDetail(order))
    }
}
```
