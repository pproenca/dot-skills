---
title: "Use Previews as Visual Smoke Tests"
impact: MEDIUM
impactDescription: "prevents 80%+ of layout regressions at development time"
tags: swiftui, previews, smoke-testing, visual
---

## Use Previews as Visual Smoke Tests

A single default preview only renders the happy-path layout, leaving empty states, error banners, long text truncation, and loading skeletons invisible until they reach production. Configuring previews for each meaningful state turns the canvas into an always-visible regression surface during development.

**Incorrect (single state leaves most layouts unverified):**

```swift
#Preview {
    PaymentStatusView(status: .success(amount: 49.99)) // only one state — errors, empty, loading never seen
}
```

**Correct (each state visible on canvas as a persistent smoke test):**

```swift
#Preview("Success") {
    PaymentStatusView(status: .success(amount: 49.99))
}

#Preview("Pending") {
    PaymentStatusView(status: .pending)
}

#Preview("Failed - Declined") {
    PaymentStatusView(status: .failed(.cardDeclined)) // error layout verified at a glance
}

#Preview("Failed - Network") {
    PaymentStatusView(status: .failed(.networkUnavailable))
}

#Preview("Loading") {
    PaymentStatusView(status: .loading) // skeleton layout stays visible during development
}
```
