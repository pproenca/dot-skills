---
title: Use _printChanges() to Diagnose Unnecessary Re-renders
impact: MEDIUM
impactDescription: 10× faster re-render diagnosis — pinpoints exact property triggering unnecessary body evaluations
tags: diff, debug, printchanges, performance, diagnostics
---

## Use _printChanges() to Diagnose Unnecessary Re-renders

When a view re-renders more often than expected, add `Self._printChanges()` at the top of the body to identify which property triggered the evaluation. The output shows the view name and the specific property that changed (or `@self` if the view's identity changed). Use this during development to find and fix over-observation — remove it before shipping.

**Incorrect (unexplained re-renders, no diagnostic output):**

```swift
struct OrderStatusBadge: View {
    var viewModel: OrderViewModel
    // Re-renders constantly but unclear why

    var body: some View {
        Label(viewModel.statusLabel, systemImage: viewModel.statusIcon)
            .foregroundStyle(viewModel.statusColor)
    }
}
```

**Correct (add _printChanges() to diagnose, then fix root cause):**

```swift
// Step 1: Add diagnostic
struct OrderStatusBadge: View {
    var viewModel: OrderViewModel

    var body: some View {
        let _ = Self._printChanges()
        // Output: "OrderStatusBadge: _viewModel changed."
        // Reveals the @Observable ViewModel triggers this view
        // even when statusLabel/statusIcon haven't changed

        Label(viewModel.statusLabel, systemImage: viewModel.statusIcon)
            .foregroundStyle(viewModel.statusColor)
    }
}

// Step 2: Fix by passing only needed properties
struct OrderStatusBadge: View {
    let statusLabel: String
    let statusIcon: String
    let statusColor: Color

    var body: some View {
        // No more unnecessary re-renders — only updates when these 3 values change
        Label(statusLabel, systemImage: statusIcon)
            .foregroundStyle(statusColor)
    }
}
```

**Common _printChanges() outputs and what they mean:**
- `"ViewName: _propertyName changed."` — that specific property triggered re-render
- `"ViewName: @self changed."` — the view's identity changed (parent recreated it)
- `"ViewName: _viewModel changed."` — an @Observable property the view reads was modified

**Important:** Remove `_printChanges()` before production — it's a debug-only API that prints to the console.

Reference: [Demystify SwiftUI performance - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
