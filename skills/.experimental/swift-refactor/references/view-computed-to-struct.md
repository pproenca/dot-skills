---
title: Convert Computed View Properties to Struct Views
impact: HIGH
impactDescription: enables independent re-evaluation and state ownership
tags: view, struct, computed-property, extraction, refactoring
---

## Convert Computed View Properties to Struct Views

Computed properties like `var headerView: some View` re-evaluate every time the parent's body runs because they are part of the parent's body evaluation. Extracting them into a separate struct gives SwiftUI an independent diffing boundary: the struct's body only re-evaluates when its specific inputs change. Additionally, struct views can own their own @State, while computed properties cannot.

**Incorrect (computed property re-evaluates on every parent body call):**

```swift
struct OrderSummaryView: View {
    @State private var order: Order
    @State private var tipPercentage: Double = 0.15

    var body: some View {
        VStack(spacing: 16) {
            headerSection
            itemsList
            tipSelector
        }
    }

    var headerSection: some View {
        // Re-evaluates when tipPercentage changes,
        // even though it only depends on order
        VStack(alignment: .leading, spacing: 4) {
            Text("Order #\(order.number)")
                .font(.title2).bold()
            Text(order.restaurant)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(order.date, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ... more computed properties
}
```

**Correct (struct view re-evaluates only when its inputs change):**

```swift
struct OrderSummaryView: View {
    @State private var order: Order
    @State private var tipPercentage: Double = 0.15

    var body: some View {
        VStack(spacing: 16) {
            OrderHeader(number: order.number,
                        restaurant: order.restaurant,
                        date: order.date)
            itemsList
            tipSelector
        }
    }

    // ... remaining subviews
}

struct OrderHeader: View {
    let number: Int
    let restaurant: String
    let date: Date

    var body: some View {
        // Only re-evaluates when number, restaurant, or date change
        VStack(alignment: .leading, spacing: 4) {
            Text("Order #\(number)")
                .font(.title2).bold()
            Text(restaurant)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(date, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

Reference: [Three ways to refactor massive SwiftUI views](https://holyswift.app/three-ways-to-refactor-massive-swiftui-views/)
