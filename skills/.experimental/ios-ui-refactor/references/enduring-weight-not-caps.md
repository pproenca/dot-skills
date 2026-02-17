---
title: Use Weight for Emphasis, Not ALL CAPS
impact: CRITICAL
impactDescription: preserves readability — all-caps body text reduces word-shape recognition and reading speed, and conflicts with VoiceOver
tags: enduring, typography, emphasis, rams-7, edson-conviction, readability
---

## Use Weight for Emphasis, Not ALL CAPS

ALL CAPS body text feels like being shouted at. It reduces word-shape recognition — we read word silhouettes, not individual letters — and it dates the interface like a print convention that never translated well to screens. Emphasis should guide the eye, not assault it. Font weight creates hierarchy through contrast without sacrificing the natural letterforms that make text scannable. The iOS emphasis system — weight and text style hierarchy — will remain correct as long as the platform exists, while uppercase styling ages the way bold wallpaper ages a room.

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

**When NOT to apply:** Legal disclaimers or regulatory labels where ALL CAPS is a legal requirement, and short status badges (1-2 words) where uppercase is a deliberate typographic convention that aids scannability.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
