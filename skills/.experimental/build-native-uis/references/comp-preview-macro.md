---
title: Use #Preview for Live Development Feedback
impact: CRITICAL
impactDescription: instant visual feedback reduces iteration time by 5-10x
tags: comp, swiftui, preview, development, iteration
---

## Use #Preview for Live Development Feedback

Without previews, every visual change requires a full build-and-run cycle on a simulator. The `#Preview` macro renders the view directly in Xcode's canvas, giving sub-second feedback on layout and styling changes. Supplying realistic sample data in previews catches edge cases like long text and missing images before they reach QA.

**Incorrect (no preview, must build and run to see changes):**

```swift
struct OrderSummaryCard: View {
    let itemName: String
    let quantity: Int
    let priceInCents: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemName)
                    .font(.headline)
                Text("Qty: \(quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$\(priceInCents / 100).\(String(format: "%02d", priceInCents % 100))")
                .font(.title3).bold()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

// No #Preview defined — requires simulator to verify layout
```

**Correct (previews with varied sample data for edge-case coverage):**

```swift
struct OrderSummaryCard: View {
    let itemName: String
    let quantity: Int
    let priceInCents: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemName)
                    .font(.headline)
                Text("Qty: \(quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$\(priceInCents / 100).\(String(format: "%02d", priceInCents % 100))")
                .font(.title3).bold()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

#Preview("Standard Item") {
    OrderSummaryCard(itemName: "Wireless Charger", quantity: 1, priceInCents: 2999)
        .padding()
}

#Preview("Long Name & High Qty") { // catches truncation and layout overflow
    OrderSummaryCard(itemName: "Ultra-Premium Noise-Cancelling Headphones Pro Max", quantity: 150, priceInCents: 34999)
        .padding()
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
