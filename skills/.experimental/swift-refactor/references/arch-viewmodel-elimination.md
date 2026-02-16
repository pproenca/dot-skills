---
title: Restructure Inline State into @Observable ViewModel
impact: HIGH
impactDescription: centralizes business logic for testability, enables property-level observation
tags: arch, viewmodel, observable, refactoring, testability
---

## Restructure Inline State into @Observable ViewModel

Views that mix @State declarations with business logic (validation, formatting, network calls) become untestable and hard to reason about. Extract state and logic into an `@Observable` class held via `@State` in the owning view. The ViewModel exposes display-ready properties and the view becomes a thin rendering layer. This enables unit testing of all logic without launching the UI.

**Incorrect (business logic mixed into view, untestable):**

```swift
struct OrderSummaryView: View {
    @State private var items: [OrderItem] = []
    @State private var promoCode: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var subtotal: Decimal {
        items.reduce(0) { $0 + $1.price * Decimal($1.quantity) }
    }

    private var discount: Decimal {
        promoCode == "SAVE20" ? subtotal * Decimal(0.20) : 0
    }

    private var total: Decimal {
        subtotal - discount
    }

    var body: some View {
        VStack {
            if isLoading { ProgressView() }
            List(items) { item in
                Text(item.name)
            }
            TextField("Promo", text: $promoCode)
            Text("Total: \(total, format: .currency(code: "USD"))")
        }
        .task {
            isLoading = true
            defer { isLoading = false }
            do {
                items = try await OrderService.shared.fetchItems()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
```

**Correct (@Observable ViewModel — testable, property-level tracking):**

```swift
@Observable
class OrderSummaryViewModel {
    var items: [OrderItem] = []
    var promoCode: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let fetchOrdersUseCase: FetchOrdersUseCase

    init(fetchOrdersUseCase: FetchOrdersUseCase) {
        self.fetchOrdersUseCase = fetchOrdersUseCase
    }

    var subtotal: Decimal {
        items.reduce(0) { $0 + $1.price * Decimal($1.quantity) }
    }

    var discount: Decimal {
        promoCode == "SAVE20" ? subtotal * Decimal(0.20) : 0
    }

    var total: Decimal {
        subtotal - discount
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await fetchOrdersUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct OrderSummaryView: View {
    @State var viewModel: OrderSummaryViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading { ProgressView() }
            List(viewModel.items) { item in
                Text(item.name)
            }
            TextField("Promo", text: $viewModel.promoCode)
            Text("Total: \(viewModel.total, format: .currency(code: "USD"))")
        }
        .task { await viewModel.loadItems() }
    }
}
```

Reference: [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/wwdc23/10149)
