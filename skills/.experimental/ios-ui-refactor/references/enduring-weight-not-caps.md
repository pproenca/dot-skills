---
title: Use Weight for Emphasis, Not ALL CAPS
impact: CRITICAL
impactDescription: preserves readability — all-caps body text reduces word-shape recognition and reading speed, and conflicts with VoiceOver
tags: enduring, typography, emphasis, rams-7, edson-conviction, readability
---

## Use Weight for Emphasis, Not ALL CAPS

Rams' longevity principle means choosing emphasis techniques that age well. ALL CAPS is a print convention that feels dated on screens — it reduces reading speed and conflicts with VoiceOver. Edson's conviction means committing to the iOS emphasis system: font weight and text style hierarchy, which will remain correct as long as iOS exists.

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
