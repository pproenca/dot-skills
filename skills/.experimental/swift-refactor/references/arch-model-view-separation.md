---
title: Separate Model Logic from View Code
impact: MEDIUM
impactDescription: enables unit testing of business logic without UI framework dependency
tags: arch, model, separation, testing, business-logic
---

## Separate Model Logic from View Code

Business logic embedded in the view body -- validation rules, data formatting, filtering -- cannot be unit tested without launching the UI. It also re-executes on every render pass, even when the inputs haven't changed. Extracting logic into plain Swift types makes it testable with simple XCTest assertions, cacheable with computed properties, and reusable across multiple views. The view becomes a thin rendering layer that calls into well-tested model code.

**Incorrect (business logic inline in view body, untestable without UI):**

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
            Text("Subtotal: $\(String(format: "%.2f", subtotal))")
            Text("Discount: -$\(String(format: "%.2f", discount))")
            Text("Tax: $\(String(format: "%.2f", tax))")
            Text("Total: $\(String(format: "%.2f", total))")
                .font(.headline)
        }
        .padding()
    }
}
```

**Correct (logic extracted to a testable model, view only renders):**

```swift
struct OrderCalculator {
    let items: [OrderItem]
    let promoCode: String

    var subtotal: Double {
        items.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
    }

    var discount: Double {
        promoCode == "SAVE20" ? subtotal * 0.20 : 0
    }

    var tax: Double {
        (subtotal - discount) * 0.08875
    }

    var total: Double {
        subtotal - discount + tax
    }

    func formatted(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}

struct OrderSummaryView: View {
    let items: [OrderItem]
    @State private var promoCode: String = ""

    private var calculator: OrderCalculator {
        OrderCalculator(items: items, promoCode: promoCode)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(calculator.formatted(item.price * Double(item.quantity)))
                }
            }
            Divider()
            TextField("Promo code", text: $promoCode)
            Text("Subtotal: \(calculator.formatted(calculator.subtotal))")
            Text("Discount: -\(calculator.formatted(calculator.discount))")
            Text("Tax: \(calculator.formatted(calculator.tax))")
            Text("Total: \(calculator.formatted(calculator.total))")
                .font(.headline)
        }
        .padding()
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
