---
title: Zero Business Logic in View Body
impact: HIGH
impactDescription: eliminates O(N) repeated computation per body evaluation — computed once in ViewModel
tags: view, business-logic, separation, viewmodel, clean-architecture
---

## Zero Business Logic in View Body

The view body is a hot path — it runs every time SwiftUI re-evaluates the view. Business logic (filtering, sorting, formatting, validation) in body runs repeatedly and violates Clean Architecture's separation. ALL business logic belongs in the ViewModel or UseCase. The view body should contain ONLY layout declarations and property references.

**Incorrect (business logic in body — re-executes on every render, untestable):**

```swift
struct OrderListView: View {
    @State var viewModel: OrderListViewModel

    var body: some View {
        List {
            // Filtering in body — runs on EVERY re-evaluation
            ForEach(viewModel.orders.filter { order in
                order.status != .cancelled &&
                order.total > 0 &&
                Calendar.current.isDate(order.date, equalTo: Date(), toGranularity: .month)
            }) { order in
                VStack(alignment: .leading) {
                    Text(order.title)

                    // Date formatting in body — creates a new formatter every render
                    Text(order.date.formatted(
                        .dateTime.month(.wide).day().year()
                    ))
                    .font(.caption)

                    // Price formatting in body — business rule embedded in view
                    Text(order.total > 100
                        ? "Free shipping"
                        : "Shipping: \(String(format: "$%.2f", order.total * 0.1))")
                    .font(.caption2)

                    // Conditional business logic in view
                    if order.items.contains(where: { $0.requiresSignature }) &&
                       order.shippingAddress.isResidential {
                        Label("Signature Required", systemImage: "pencil.line")
                    }
                }
            }
        }
    }
}
```

**Correct (view reads display-ready properties — logic lives in ViewModel):**

```swift
struct OrderListView: View {
    @State var viewModel: OrderListViewModel

    var body: some View {
        // Body contains ONLY layout declarations and property references
        List {
            ForEach(viewModel.currentMonthOrders) { order in
                OrderRowView(
                    title: order.title,
                    formattedDate: order.formattedDate,
                    shippingLabel: order.shippingLabel,
                    requiresSignature: order.requiresSignature
                )
            }
        }
    }
}

// ViewModel owns ALL business logic — testable without UI
@Observable
final class OrderListViewModel {
    private let fetchOrdersUseCase: FetchOrdersUseCase

    // Pre-filtered — view never sees cancelled or zero-total orders
    var currentMonthOrders: [OrderDisplayItem] = []

    func loadOrders() async {
        let orders = try? await fetchOrdersUseCase.execute()
        currentMonthOrders = (orders ?? [])
            .filter { $0.status != .cancelled && $0.total > 0 }
            .filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .map { OrderDisplayItem(from: $0) }
    }
}

// Display model — pre-formatted, ready for view consumption
struct OrderDisplayItem: Identifiable {
    let id: String
    let title: String
    let formattedDate: String    // Pre-formatted in ViewModel
    let shippingLabel: String    // Business rule computed once
    let requiresSignature: Bool  // Pre-evaluated boolean
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
