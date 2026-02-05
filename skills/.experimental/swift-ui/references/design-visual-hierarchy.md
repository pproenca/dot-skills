---
title: Establish Clear Visual Hierarchy
impact: CRITICAL
impactDescription: guides user attention and improves comprehension
tags: design, hierarchy, typography, contrast, layout
---

## Establish Clear Visual Hierarchy

Visual hierarchy uses size, weight, color, and spacing to communicate importance. Every screen should have a clear primary, secondary, and tertiary information level.

**Incorrect (flat hierarchy, everything same weight):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.body)  // Same weight
            Text(product.category)
                .font(.body)  // Same weight
            Text(product.price)
                .font(.body)  // Same weight
            Text(product.description)
                .font(.body)  // Everything looks the same
        }
    }
}
```

**Correct (clear information hierarchy):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.category)
                .font(.caption)
                .foregroundStyle(.secondary)  // Tertiary: context

            Text(product.name)
                .font(.headline)  // Primary: most important

            Text(product.price)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.accentColor)  // Secondary: key info

            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)  // Tertiary: supporting
        }
    }
}
```

**Hierarchy techniques:**

| Level | Size | Weight | Color |
|-------|------|--------|-------|
| Primary | .headline+ | .semibold+ | .primary |
| Secondary | .body | .regular | .primary |
| Tertiary | .subheadline- | .regular | .secondary |
| Metadata | .caption | .regular | .tertiary |

**Apple's Weather app example:**
- Temperature: `.system(size: 96)` - Hero
- Condition: `.title2` - Primary
- High/Low: `.title3` - Secondary
- Details: `.body` - Tertiary

Reference: [Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
