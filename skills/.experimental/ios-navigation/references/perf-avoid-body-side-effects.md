---
title: Avoid Side Effects in View Body
impact: MEDIUM
impactDescription: prevents re-computation on every SwiftUI render pass
tags: perf, body, side-effects, render-pass
---

## Avoid Side Effects in View Body

SwiftUI may evaluate `body` multiple times per state change for diffing and layout purposes. Any side effects placed directly in `body` — network calls, analytics events, logging, file writes — will execute on every render pass. This causes duplicate analytics events, redundant API calls, and unpredictable behavior. Use `.onAppear`, `.task`, or `.onChange` to trigger side effects at well-defined lifecycle moments.

**Incorrect (side effects in body — runs on every render pass):**

```swift
struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()

    var body: some View {
        // BAD: body may be called 3-5 times per state change
        // for diffing. Each call fires an analytics event.
        // Result: "checkout_viewed" logged 3-5x per navigation.
        AnalyticsService.shared.track("checkout_viewed")

        // BAD: Print runs on every render — floods console,
        // makes debugging harder, wastes CPU on string interpolation.
        print("Rendering checkout with \(viewModel.items.count) items")

        return VStack {
            // BAD: Network call in body. If any @State changes
            // (e.g., user toggles a switch), this fetches again.
            let _ = Task { await viewModel.refreshPricing() }

            ForEach(viewModel.items) { item in
                CheckoutRowView(item: item)
            }

            Button("Pay") {
                viewModel.submitOrder()
            }
        }
    }
}
```

**Correct (side effects in lifecycle modifiers):**

```swift
struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()

    var body: some View {
        // body is pure — no side effects, only view construction.
        // SwiftUI can call this as many times as needed for diffing.
        VStack {
            if viewModel.isLoading {
                ProgressView("Updating prices...")
            }

            ForEach(viewModel.items) { item in
                CheckoutRowView(item: item)
            }

            Button("Pay") {
                viewModel.submitOrder()
            }
        }
        // .onAppear: fires once when the view enters the hierarchy.
        // Analytics tracked exactly once per navigation.
        .onAppear {
            AnalyticsService.shared.track("checkout_viewed")
        }
        // .task: fires once on appear, auto-cancels on disappear.
        // Network call happens once, not on every render pass.
        .task {
            await viewModel.refreshPricing()
        }
        // .onChange: fires only when a specific value changes,
        // not on every unrelated state change.
        .onChange(of: viewModel.promoCode) { _, newCode in
            Task { await viewModel.applyPromo(newCode) }
        }
    }
}
```
