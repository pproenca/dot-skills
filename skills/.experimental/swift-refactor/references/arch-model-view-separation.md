---
title: Extract Business Logic into ViewModel and Use Cases
impact: HIGH
impactDescription: enables unit testing of business logic without UI framework dependency
tags: arch, viewmodel, usecase, separation, clean-architecture
---

## Extract Business Logic into ViewModel and Use Cases

Business logic embedded in the view body — validation, formatting, network calls, data transformation — cannot be unit tested without launching the UI. Extract logic into an `@Observable` ViewModel that delegates to domain Use Cases. The view becomes a thin rendering layer, the ViewModel exposes display-ready state, and Use Cases contain reusable business rules testable with plain XCTest.

**Incorrect (business logic inline in view body, untestable):**

```swift
struct OrderSummaryView: View {
    let items: [OrderItem]
    @State private var promoCode: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                }
            }

            let subtotal = items.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
            let discount = promoCode == "SAVE20" ? subtotal * 0.20 : 0
            let tax = (subtotal - discount) * 0.08875
            let total = subtotal - discount + tax

            Divider()
            TextField("Promo code", text: $promoCode)
            Text("Total: $\(String(format: "%.2f", total))")
                .font(.headline)
        }
    }
}
```

**Correct (ViewModel + Use Case — testable, clean layer separation):**

```swift
// Domain layer — pure Swift, zero framework imports
protocol CalculateOrderTotalUseCase {
    func execute(items: [OrderItem], promoCode: String) -> OrderTotal
}

struct OrderTotal: Equatable {
    let subtotal: Decimal
    let discount: Decimal
    let tax: Decimal
    let total: Decimal
}

final class CalculateOrderTotalUseCaseImpl: CalculateOrderTotalUseCase {
    func execute(items: [OrderItem], promoCode: String) -> OrderTotal {
        let subtotal = items.reduce(Decimal.zero) { $0 + $1.price * Decimal($1.quantity) }
        let discount = promoCode == "SAVE20" ? subtotal * Decimal(0.20) : Decimal.zero
        let tax = (subtotal - discount) * Decimal(string: "0.08875")!
        let total = subtotal - discount + tax
        return OrderTotal(subtotal: subtotal, discount: discount, tax: tax, total: total)
    }
}

// Presentation layer — @Observable ViewModel
@Observable
class OrderSummaryViewModel {
    var promoCode: String = ""

    private let items: [OrderItem]
    private let calculateTotal: CalculateOrderTotalUseCase

    init(items: [OrderItem], calculateTotal: CalculateOrderTotalUseCase) {
        self.items = items
        self.calculateTotal = calculateTotal
    }

    var orderTotal: OrderTotal {
        calculateTotal.execute(items: items, promoCode: promoCode)
    }
}

// View — thin rendering layer
struct OrderSummaryView: View {
    @State var viewModel: OrderSummaryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Promo code", text: $viewModel.promoCode)
            Text("Total: \(viewModel.orderTotal.total, format: .currency(code: "USD"))")
                .font(.headline)
        }
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
