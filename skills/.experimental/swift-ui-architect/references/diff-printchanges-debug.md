---
title: Use _printChanges() to Diagnose Unnecessary Body Evaluations
impact: MEDIUM
impactDescription: 10× faster debugging — pinpoints exact dependency causing re-render in one line
tags: diff, debugging, printchanges, profiling, instruments
---

## Use _printChanges() to Diagnose Unnecessary Body Evaluations

When a view re-renders unexpectedly, add `let _ = Self._printChanges()` at the top of the body to log which dependency triggered the update. This reveals over-broad dependencies, non-diffable properties, and cascade re-renders. NEVER ship to production — the underscore prefix indicates an unstable API.

**Incorrect (guessing at re-render causes — adding optimization without evidence):**

```swift
struct ProductList: View {
    let viewModel: ProductListViewModel

    var body: some View {
        // "It feels slow, let me add caching everywhere"
        // No evidence of what's actually causing re-renders
        List {
            ForEach(viewModel.products) { product in
                ProductRow(product: product)
            }
        }
    }
}
```

**Correct (_printChanges() in debug — identify the root cause, then fix it):**

```swift
struct ProductList: View {
    let viewModel: ProductListViewModel

    var body: some View {
        // Step 1: Add _printChanges() to identify the trigger
        let _ = Self._printChanges()
        // Console output examples:
        //   "ProductList: @self changed."     → view struct itself was recreated
        //   "ProductList: _viewModel changed." → viewModel reference changed
        //   "ProductList: @identity changed."  → structural identity changed

        List {
            ForEach(viewModel.products) { product in
                ProductRow(product: product)
            }
        }
    }
}

// Step 2: Read the log and fix the root cause
// "@self changed" → parent is recreating this view (check @Equatable)
// "_viewModel changed" → new ViewModel instance each render (check @State ownership)
// "@identity changed" → view position in hierarchy shifted (check conditional logic)
```

**When NOT to use:** Production builds — `_printChanges()` has runtime overhead and is not API-stable. Remove before shipping.

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
