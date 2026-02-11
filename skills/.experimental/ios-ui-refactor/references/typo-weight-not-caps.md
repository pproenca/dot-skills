---
title: Use Weight for Emphasis, Not ALL CAPS
impact: CRITICAL
impactDescription: preserves readability — all-caps body text reduces reading speed by 13-20% (Tinker, 1963), breaks iOS text conventions
tags: typo, emphasis, weight, readability
---

## Use Weight for Emphasis, Not ALL CAPS

Uppercase body text and section headers are a legacy print convention that does not translate to iOS. All-caps text reduces word-shape recognition, slowing reading speed measurably. It also signals "shouting" in digital contexts and collides with VoiceOver, which may spell out acronym-like words letter by letter. iOS uses font weight and semantic text styles as the primary emphasis mechanism — `.headline` is already semibold, and bumping to `.fontWeight(.bold)` provides a clear visual step without sacrificing scan speed.

**Incorrect (ALL CAPS for emphasis on section headers and body content):**

```swift
struct OrderSummaryView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Details")
                .font(.body)
                .textCase(.uppercase)
                .tracking(1.2)

            Text("Shipping Address")
                .font(.subheadline)
                .textCase(.uppercase)

            Text(order.address)
                .font(.body)

            Text("Payment Method")
                .font(.subheadline)
                .textCase(.uppercase)

            Text(order.paymentSummary)
                .font(.body)
        }
    }
}
```

**Correct (weight and text style hierarchy for emphasis):**

```swift
struct OrderSummaryView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Details")
                .font(.headline)

            Text("Shipping Address")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(order.address)
                .font(.body)

            Text("Payment Method")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(order.paymentSummary)
                .font(.body)
        }
    }
}
```

**When ALL CAPS is acceptable:**
- Short status badges or tags (e.g., `Text("NEW").font(.caption2).textCase(.uppercase)`) where the text is 1-2 words, purely decorative, and not the primary reading content.
- Tab bar labels or segmented control items that follow platform convention.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
