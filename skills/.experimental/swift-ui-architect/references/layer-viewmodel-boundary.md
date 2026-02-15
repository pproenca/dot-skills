---
title: Expose Display-Ready State Only From ViewModels
impact: MEDIUM-HIGH
impactDescription: eliminates N formatting operations per body re-render — computed once in ViewModel
tags: layer, viewmodel, display-state, boundary, formatting
---

## Expose Display-Ready State Only From ViewModels

ViewModels transform domain models into display-ready properties. Views should NEVER receive raw domain models — they receive formatted strings, computed booleans, and pre-processed collections. This prevents business model changes from rippling into views and keeps formatting logic testable in the ViewModel.

**Incorrect (ViewModel exposing raw domain models — view forced to format and transform):**

```swift
@Observable
final class OrderDetailViewModel {
    private let fetchOrderUseCase: FetchOrderUseCase

    // Leaking domain model directly to view
    var order: Order?

    func loadOrder() async {
        order = try? await fetchOrderUseCase.execute(orderId: orderId)
    }

    private let orderId: String

    init(orderId: String, fetchOrderUseCase: FetchOrderUseCase) {
        self.orderId = orderId
        self.fetchOrderUseCase = fetchOrderUseCase
    }
}

struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel

    var body: some View {
        if let order = viewModel.order {
            VStack(alignment: .leading) {
                // Formatting in view body — runs on every re-render
                Text("Order #\(order.id.prefix(8).uppercased())")
                    .font(.headline)

                // Date formatting in view — creates formatter every render
                Text("Placed: \(order.createdAt.formatted(.dateTime.month(.wide).day().year()))")

                // Business logic in view — price calculation
                let subtotal = order.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
                let tax = subtotal * 0.08
                let total = subtotal + tax

                Text("Subtotal: $\(String(format: "%.2f", subtotal))")
                Text("Tax: $\(String(format: "%.2f", tax))")
                Text("Total: $\(String(format: "%.2f", total))")
                    .bold()

                // Status formatting in view
                HStack {
                    Circle()
                        .fill(order.status == .delivered ? .green :
                              order.status == .shipped ? .blue :
                              order.status == .processing ? .orange : .gray)
                        .frame(width: 8, height: 8)
                    Text(order.status.rawValue.capitalized)
                }
            }
        }
    }
}
```

**Correct (ViewModel exposes display-ready properties — view is a pure template):**

```swift
@Observable
final class OrderDetailViewModel {
    private let fetchOrderUseCase: FetchOrderUseCase
    private let orderId: String

    // Display-ready properties — pre-formatted, pre-computed
    var orderNumber: String = ""
    var placedDate: String = ""
    var subtotalLabel: String = ""
    var taxLabel: String = ""
    var totalLabel: String = ""
    var statusLabel: String = ""
    var statusColor: StatusColor = .gray
    var isLoading: Bool = false
    var errorMessage: String?

    enum StatusColor {
        case green, blue, orange, gray
    }

    init(orderId: String, fetchOrderUseCase: FetchOrderUseCase) {
        self.orderId = orderId
        self.fetchOrderUseCase = fetchOrderUseCase
    }

    func loadOrder() async {
        isLoading = true
        defer { isLoading = false }

        guard let order = try? await fetchOrderUseCase.execute(orderId: orderId) else {
            errorMessage = "Failed to load order"
            return
        }

        // All formatting happens ONCE in the ViewModel — testable without UI
        orderNumber = "Order #\(order.id.prefix(8).uppercased())"
        placedDate = "Placed: \(Self.dateFormatter.string(from: order.createdAt))"

        let subtotal = order.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
        let tax = subtotal * 0.08
        let total = subtotal + tax

        subtotalLabel = Self.currencyFormatter.string(from: NSNumber(value: subtotal)) ?? ""
        taxLabel = Self.currencyFormatter.string(from: NSNumber(value: tax)) ?? ""
        totalLabel = Self.currencyFormatter.string(from: NSNumber(value: total)) ?? ""

        statusLabel = order.status.rawValue.capitalized
        statusColor = switch order.status {
        case .delivered: .green
        case .shipped: .blue
        case .processing: .orange
        default: .gray
        }
    }

    // Formatters created once, reused — not recreated every render
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f
    }()
}

// View is a pure template — only layout and property references
struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.orderNumber)
                .font(.headline)

            Text(viewModel.placedDate)

            Text(viewModel.subtotalLabel)
            Text(viewModel.taxLabel)
            Text(viewModel.totalLabel)
                .bold()

            OrderStatusBadge(
                label: viewModel.statusLabel,
                color: viewModel.statusColor
            )
        }
        .task {
            await viewModel.loadOrder()
        }
    }
}

// Testing — verify formatting without any UI
@Test func orderFormattingIsCorrect() async {
    let mockUseCase = MockFetchOrderUseCase(
        stubbedOrder: .fixture(status: .delivered, total: 99.99)
    )
    let viewModel = OrderDetailViewModel(
        orderId: "test",
        fetchOrderUseCase: mockUseCase
    )

    await viewModel.loadOrder()

    #expect(viewModel.statusLabel == "Delivered")
    #expect(viewModel.statusColor == .green)
    #expect(viewModel.totalLabel == "$107.99")  // with tax
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
