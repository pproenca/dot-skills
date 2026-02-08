---
title: Use Result Type Over Optional with Error Flag
impact: LOW-MEDIUM
impactDescription: eliminates impossible states (data and error both non-nil)
tags: type, result, optionals, error-handling, state-modeling
---

## Use Result Type Over Optional with Error Flag

A pair of optionals (`data: T?` + `errorMessage: String?`) creates four possible states -- nil/nil, nil/value, value/nil, and value/value -- but only two are semantically valid. Nothing prevents the view from showing an error banner while simultaneously rendering stale data. Modeling load state as an enum makes impossible combinations unrepresentable and forces every call site to handle each case explicitly.

**Incorrect (optional pair allows contradictory states):**

```swift
struct OrderListView: View {
    @State private var orders: [Order]?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let errorMessage {
                ErrorBanner(message: errorMessage)
            } else if let orders {
                List(orders) { order in OrderRow(order: order) }
            }
        }
        // Bug: nothing prevents orders AND errorMessage
        // from both being non-nil after a retry
    }
}
```

**Correct (enum makes impossible states unrepresentable):**

```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}

struct OrderListView: View {
    @State private var state: LoadingState<[Order]> = .idle

    var body: some View {
        Group {
            switch state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let orders):
                List(orders) { order in OrderRow(order: order) }
            case .failed(let error):
                ErrorBanner(message: error.localizedDescription)
            }
        }
    }
}
```

Reference: [Result](https://developer.apple.com/documentation/swift/result)
