---
title: Use @ViewBuilder for Conditional View Composition
impact: MEDIUM-HIGH
impactDescription: preserves structural identity across conditional branches
tags: view, viewbuilder, conditional, composition, identity
---

## Use @ViewBuilder for Conditional View Composition

When views need to vary based on conditions, use `@ViewBuilder` to preserve SwiftUI's structural identity tracking. This allows the diff engine to track each branch independently. Avoid using `AnyView`, `Group` with mixed types, or complex ternary operators in body.

**Incorrect (AnyView erases type identity — full subtree teardown on branch switch):**

```swift
struct PaymentMethodView: View {
    let method: PaymentMethod

    var body: some View {
        paymentContent()
    }

    // AnyView destroys structural identity
    // SwiftUI tears down and recreates the entire subtree
    // when switching between payment methods
    func paymentContent() -> AnyView {
        switch method {
        case .creditCard(let card):
            return AnyView(
                HStack {
                    Image(systemName: "creditcard.fill")
                    VStack(alignment: .leading) {
                        Text("**** \(card.lastFour)")
                        Text(card.expiryDate)
                            .font(.caption)
                    }
                }
            )
        case .applePay:
            return AnyView(
                Label("Apple Pay", systemImage: "apple.logo")
            )
        case .bankTransfer(let bank):
            return AnyView(
                HStack {
                    Image(systemName: "building.columns.fill")
                    Text(bank.name)
                }
            )
        }
    }
}
```

**Correct (@ViewBuilder preserves structural identity — each branch tracked independently):**

```swift
struct PaymentMethodView: View {
    let method: PaymentMethod

    var body: some View {
        paymentContent
    }

    // @ViewBuilder preserves concrete types per branch
    // SwiftUI assigns stable structural identity to each case
    // Transitions between branches are smooth and animatable
    @ViewBuilder
    var paymentContent: some View {
        switch method {
        case .creditCard(let card):
            HStack {
                Image(systemName: "creditcard.fill")
                VStack(alignment: .leading) {
                    Text("**** \(card.lastFour)")
                    Text(card.expiryDate)
                        .font(.caption)
                }
            }
        case .applePay:
            Label("Apple Pay", systemImage: "apple.logo")
        case .bankTransfer(let bank):
            HStack {
                Image(systemName: "building.columns.fill")
                Text(bank.name)
            }
        }
    }
}
```

**Alternative (@ViewBuilder closure parameter for reusable containers):**

```swift
// Generic container with @ViewBuilder closure
// Caller's concrete view types are preserved through the closure
struct FeatureCard<Content: View>: View {
    let title: String
    let isHighlighted: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(isHighlighted ? .orange : .primary)

            content()  // Concrete type preserved — diffable
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Usage — SwiftUI knows the exact type inside the closure
FeatureCard(title: "Recent Orders", isHighlighted: true) {
    ForEach(orders.prefix(3)) { order in
        OrderRowView(order: order)
    }
}
```

Reference: [Apple Documentation — ViewBuilder](https://developer.apple.com/documentation/swiftui/viewbuilder)
