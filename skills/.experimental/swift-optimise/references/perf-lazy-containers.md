---
title: Use Lazy Containers for Large Collections
impact: HIGH
impactDescription: reduces initial view allocations from O(total) to O(visible), cutting memory from ~1000 views to ~20 for large lists
tags: perf, lazy, lazyvstack, lazyhstack, lazyvgrid, memory, virtualization
---

## Use Lazy Containers for Large Collections

Non-lazy stacks instantiate every child view upfront, even those far off-screen. For a collection of 1,000+ items, this means 1,000+ view allocations, body evaluations, and layout passes on initial load. `LazyVStack` and `LazyHStack` only create views as they scroll into the visible area, reducing initial work from O(total) to O(visible).

**Memory comparison:**
- VStack with 1000 rows: ~1000 views in memory
- LazyVStack with 1000 rows: ~20 views in memory (visible + buffer)

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

**Lazy grid for galleries:**

```swift
struct PhotoGallery: View {
    let photos: [Photo]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.thumbnailURL)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
}
```

**Combining with pagination:**

```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }

    if hasMoreItems {
        ProgressView()
            .onAppear { loadMoreItems() }
    }
}
```

**When NOT to use Lazy:**
- Small, fixed collections (< 20 items) -- regular stacks avoid lazy container bookkeeping overhead
- When you need simultaneous animations
- When using `.id()` modifier (can break lazy loading)

Reference: [Creating Performant Scrollable Stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)
