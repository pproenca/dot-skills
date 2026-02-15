---
title: Ensure Constant View Count Per ForEach Element
impact: MEDIUM
impactDescription: prevents O(N) eager view instantiation — maintains O(visible) lazy loading
tags: list, foreach, constant, view-count, identity
---

## Ensure Constant View Count Per ForEach Element

When `ForEach` produces a variable number of views per element (via `if`/`else` with different view counts), SwiftUI cannot predict the total row count. It must instantiate ALL views upfront to gather identifiers, destroying lazy loading benefits. This means a `LazyVStack` with 10,000 items behaves like a regular `VStack` — all 10,000 views are created immediately. Ensure each `ForEach` iteration produces exactly 1 view (or a fixed number).

**Incorrect (variable view count per element — breaks lazy loading):**

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            // VARIABLE view count: sometimes 0 views, sometimes 1
            // SwiftUI must build ALL items to count total views
            if item.isVisible {
                ItemRow(item: item)
            }
            // When isVisible is false, this iteration produces 0 views
            // When isVisible is true, it produces 1 view
            // SwiftUI can't predict the count without evaluating every element
        }
    }
}
```

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            // VARIABLE view count: 1 view vs 2 views per iteration
            ItemRow(item: item)
            if item.hasSubtitle {
                SubtitleRow(text: item.subtitle)
            }
            // Some iterations produce 1 view, others produce 2
        }
    }
}
```

**Correct (constant view count — exactly 1 view per element, lazy loading preserved):**

```swift
ScrollView {
    LazyVStack {
        // Option 1: Filter in the model layer BEFORE ForEach
        ForEach(viewModel.visibleItems) { item in
            ItemRow(item: item)
            // Always exactly 1 view per iteration
        }
    }
}
```

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            // Option 2: Always produce 1 view, control visibility via opacity
            ItemRow(item: item)
                .opacity(item.isVisible ? 1 : 0)
                .frame(height: item.isVisible ? nil : 0)
            // Constant 1 view per iteration — SwiftUI can predict count
        }
    }
}
```

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            // Option 3: Wrap conditional content in a single container
            VStack(spacing: 0) {
                ItemRow(item: item)
                if item.hasSubtitle {
                    SubtitleRow(text: item.subtitle)
                }
            }
            // Always exactly 1 VStack per iteration — constant view count
        }
    }
}
```

**Why this matters:**
- Lazy stacks determine which items to render based on scroll position and predicted item count
- Variable view counts make prediction impossible — SwiftUI falls back to eager instantiation
- A 10,000-item lazy list becomes O(N) instead of O(visible) on initial load

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
