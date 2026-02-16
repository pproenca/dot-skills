---
title: Establish Clear Visual Hierarchy Through Size, Weight, and Color
impact: CRITICAL
impactDescription: flat hierarchy forces users to read every element sequentially — clear primary/secondary/tertiary levels reduce time-to-comprehension to under 2 seconds per screen
tags: system, hierarchy, typography, contrast, kocienda-convergence, edson-systems
---

## Establish Clear Visual Hierarchy Through Size, Weight, and Color

Edson's systems thinking means every element on screen exists in relationship to every other element — size, weight, and color establish that relationship hierarchy. Kocienda's convergence process works the same way: the iPhone keyboard's key labels weren't all the same size; the most likely next letter got a subtly larger touch target. The visual system communicates importance without words. When every `Text` on screen uses `.body` with `.primary` color, the user must read linearly to understand what matters. A principal designer uses the type scale, font weight, and foreground style as three independent levers that combine into an unmistakable hierarchy.

**Incorrect (flat hierarchy — everything at the same visual weight):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.body)
            Text(product.category)
                .font(.body)
            Text(product.price)
                .font(.body)
            Text(product.description)
                .font(.body)
        }
    }
}
```

**Correct (clear primary, secondary, tertiary information levels):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.category)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(product.name)
                .font(.headline)

            Text(product.price)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.tint)

            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
}
```

**Hierarchy system:**
| Level | Font Scale | Weight | Foreground Style |
|-------|-----------|--------|-----------------|
| Primary | `.headline`+ | `.semibold`+ | `.primary` |
| Secondary | `.body` | `.regular` | `.primary` or `.tint` |
| Tertiary | `.subheadline`- | `.regular` | `.secondary` |
| Metadata | `.caption` | `.regular` | `.tertiary` |

**Squint test:** Blur your eyes or step back from the screen. Only the primary element should remain visible. If two or more elements compete, the hierarchy is broken.

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
