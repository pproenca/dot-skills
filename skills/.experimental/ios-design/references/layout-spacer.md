---
title: Use Spacer for Flexible Space Distribution
impact: HIGH
impactDescription: Spacer replaces 3-5 lines of manual padding/offset math with a single declarative element — eliminates pixel-level alignment bugs and reduces layout code by 30-50% in toolbar and row patterns
tags: layout, spacer, distribution, edson-design-out-loud, kocienda-intersection
---

## Use Spacer for Flexible Space Distribution

Edson's "Design Out Loud" means arranging and rearranging until the spatial relationships feel right. `Spacer` is SwiftUI's flexible spring — it expands to fill available space, pushing content to the edges or creating proportional gaps. Without it, `HStack` content clusters at center and `VStack` content stacks tightly. Kocienda's intersection principle means layout should feel as natural as physical objects arranged on a table — Spacer provides the invisible force that organizes them.

**Incorrect (content clusters without spatial intent):**

```swift
struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack {
            // Everything bunches to the left
            Text(order.number)
                .font(.headline)
            Text(order.date.formatted())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(order.total, format: .currency(code: "USD"))
                .font(.subheadline.bold())
        }
    }
}
```

**Correct (Spacer distributes content with intent):**

```swift
struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(order.number)
                    .font(.headline)
                Text(order.date.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(order.total, format: .currency(code: "USD"))
                .font(.subheadline.bold())
        }
    }
}
```

**Spacer patterns:**

```swift
// Push content to trailing edge
HStack {
    Text("Label")
    Spacer()
    Text("Value")
}

// Push content to bottom
VStack {
    Text("Title")
    Spacer()
    Button("Action") { }
}

// Center content with equal margins
HStack {
    Spacer()
    Text("Centered")
    Spacer()
}

// Minimum spacing
Spacer(minLength: 16)
```

**When NOT to use Spacer:** Inside `List` rows (the row itself handles spacing), inside `Form` sections (system manages layout), or when padding achieves the same result more simply. Don't use `Spacer()` when `.frame(maxWidth: .infinity, alignment: .leading)` would be clearer.

Reference: [Spacer - Apple Documentation](https://developer.apple.com/documentation/swiftui/spacer)
