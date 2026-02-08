---
title: Migrate VStack/HStack to Lazy Variants for Large Collections
impact: LOW
impactDescription: loads only visible items, O(visible) instead of O(total)
tags: perf, lazy, vstack, scrollview, virtualization
---

## Migrate VStack/HStack to Lazy Variants for Large Collections

Non-lazy stacks instantiate every child view upfront, even those far off-screen. For a collection of 1,000+ items, this means 1,000+ view allocations, body evaluations, and layout passes on initial load. `LazyVStack` and `LazyHStack` only create views as they scroll into the visible area, reducing initial work from O(total) to O(visible). Note: only use lazy variants for large (50+) collections -- small lists are faster with regular stacks because they avoid the lazy container's bookkeeping overhead.

**Incorrect (all items instantiated upfront, even off-screen):**

```swift
struct TransactionHistoryView: View {
    let transactions: [Transaction]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            // All 1,000+ TransactionRow views are created
            // immediately, causing a multi-second hang
        }
    }
}
```

**Correct (only visible items are instantiated on demand):**

```swift
struct TransactionHistoryView: View {
    let transactions: [Transaction]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            // Only the ~15 visible TransactionRow views are
            // created; the rest load as the user scrolls
        }
    }
}
```

Reference: [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack)
