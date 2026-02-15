---
title: Extract Computed Properties and Helpers Into Separate View Structs
impact: HIGH
impactDescription: 2-5× fewer body evaluations — extracted subviews diff independently
tags: view, extraction, computed-properties, subviews, diffing
---

## Extract Computed Properties and Helpers Into Separate View Structs

Computed properties, helper functions, and closures defined within a view body are "inlined" by SwiftUI at runtime — they cannot be independently diffed. This means ANY change to ANY dependency triggers re-evaluation of ALL inlined content. Extract these into separate View structs that receive only their required data as stored properties.

**Incorrect (helper methods and computed properties — inlined, cannot be independently diffed):**

```swift
struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel

    // Computed property — inlined into body, re-evaluated on ANY state change
    var headerView: some View {
        VStack {
            Text(viewModel.orderTitle)
                .font(.title)
            Text(viewModel.orderDate)
                .font(.caption)
        }
    }

    // Helper function — also inlined, no independent diffing
    private func itemRow(_ item: OrderItem) -> some View {
        HStack {
            Text(item.name)
            Spacer()
            Text(item.formattedPrice)
                .bold()
        }
    }

    // Another helper — all three re-evaluate together
    private func footerView() -> some View {
        VStack {
            Divider()
            HStack {
                Text("Total")
                Spacer()
                Text(viewModel.formattedTotal)
                    .font(.headline)
            }
        }
    }

    var body: some View {
        ScrollView {
            headerView  // inlined — not a separate diffing unit
            ForEach(viewModel.items) { item in
                itemRow(item)  // inlined — not a separate diffing unit
            }
            footerView()  // inlined — not a separate diffing unit
        }
    }
}
```

**Correct (extracted view structs — each is an independent diffing unit):**

```swift
struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel

    var body: some View {
        ScrollView {
            // Each is a separate View struct — SwiftUI diffs independently
            OrderHeaderView(
                title: viewModel.orderTitle,
                date: viewModel.orderDate
            )

            ForEach(viewModel.items) { item in
                OrderItemRow(
                    name: item.name,
                    formattedPrice: item.formattedPrice
                )
            }

            OrderFooterView(formattedTotal: viewModel.formattedTotal)
        }
    }
}

// Separate struct — only re-evaluates when title or date change
struct OrderHeaderView: View {
    let title: String
    let date: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
            Text(date)
                .font(.caption)
        }
    }
}

// Separate struct — only re-evaluates when this item's data changes
struct OrderItemRow: View {
    let name: String
    let formattedPrice: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(formattedPrice)
                .bold()
        }
    }
}

// Separate struct — only re-evaluates when total changes
struct OrderFooterView: View {
    let formattedTotal: String

    var body: some View {
        VStack {
            Divider()
            HStack {
                Text("Total")
                Spacer()
                Text(formattedTotal)
                    .font(.headline)
            }
        }
    }
}
```

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-b1e8e4a78688)
