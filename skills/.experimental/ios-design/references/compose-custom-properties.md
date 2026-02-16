---
title: Use Properties to Make Views Configurable
impact: HIGH
impactDescription: hardcoded values inside views prevent reuse — configurable properties let the same view serve 5-10 different contexts without code duplication
tags: compose, properties, reuse, kocienda-creative-selection, configuration
---

## Use Properties to Make Views Configurable

Kocienda's creative selection means building small pieces that can be recombined into different wholes. A view with hardcoded text, colors, and sizes can only serve one context. A view with properties for content, style, and behavior can be recombined into dozens of contexts. This is the difference between a one-off implementation and a reusable component — the same effort, vastly more value.

**Incorrect (hardcoded values prevent reuse):**

```swift
struct StatusBadge: View {
    var body: some View {
        Text("Active")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.green, in: Capsule())
    }
}
// Only works for "Active" in green — need a new view for every status
```

**Correct (configurable properties enable reuse):**

```swift
struct StatusBadge: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }
}

// One view, many contexts
StatusBadge(title: "Active", color: .green)
StatusBadge(title: "Pending", color: .orange)
StatusBadge(title: "Expired", color: .red)
StatusBadge(title: "Draft", color: .secondary)
```

**Progressive configuration with defaults:**

```swift
struct MetricCard: View {
    let title: String
    let value: String
    var icon: String = "chart.bar.fill"
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(tint)

            Text(value)
                .font(.title.bold())
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Minimal configuration
MetricCard(title: "Revenue", value: "$12,430")

// Full configuration
MetricCard(title: "Orders", value: "84", icon: "bag.fill", tint: .purple)
```

**When NOT to add properties:** Don't pre-emptively make everything configurable. Start with hardcoded values and extract properties only when you need the same view in a second context. Premature configuration adds complexity without value.

Reference: [View fundamentals - Apple Documentation](https://developer.apple.com/documentation/swiftui/view-fundamentals)
