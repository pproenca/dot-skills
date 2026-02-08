---
title: Add Equatable Conformance to Prevent Spurious Redraws
impact: LOW
impactDescription: skips 100% of redundant body re-evaluations when inputs are unchanged
tags: perf, equatable, diffing, re-renders, optimization
---

## Add Equatable Conformance to Prevent Spurious Redraws

SwiftUI compares view structs to decide whether `body` needs re-evaluation. When a view receives a closure or a non-Equatable property, SwiftUI cannot prove equality and conservatively re-evaluates `body` on every parent invalidation. Adding `Equatable` conformance with a custom `==` that compares only the meaningful inputs lets SwiftUI skip body re-evaluation when the view's semantic content has not changed.

**Incorrect (closure property forces re-evaluation every time):**

```swift
struct MetricCard: View {
    let title: String
    let value: Int
    let onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title.bold())
        }
        .onTapGesture { onTap() }
        // SwiftUI cannot compare closures, so body
        // re-evaluates on every parent invalidation
    }
}
```

**Correct (Equatable conformance lets SwiftUI skip unchanged views):**

```swift
struct MetricCard: View, Equatable {
    let title: String
    let value: Int
    let onTap: () -> Void

    static func == (lhs: MetricCard, rhs: MetricCard) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title.bold())
        }
        .onTapGesture { onTap() }
        // SwiftUI uses == to skip body when title and value
        // are unchanged, even though the closure is new
    }
}
```

Reference: [EquatableView](https://developer.apple.com/documentation/swiftui/equatableview)
