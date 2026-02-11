---
title: Limit to 3-4 Distinct Type Treatments Per Screen
impact: CRITICAL
impactDescription: reduces cognitive load — Miller's Law suggests 7±2 chunks; exceeding 4 type treatments consumes chunk capacity on chrome instead of content
tags: typo, hierarchy, visual-rhythm, cognitive-load
---

## Limit to 3-4 Distinct Type Treatments Per Screen

A "type treatment" is a unique combination of text style, weight, and color. When a screen uses 6 or more treatments, every piece of text demands a separate parsing decision from the reader — is this a heading, a label, a value, a caption? Apple's own screens rarely exceed three levels. Look at Apple Music's Now Playing: large title (song name), body (artist), caption (album) — three treatments that create an instantly scannable hierarchy. Every additional level flattens the hierarchy rather than enriching it.

**Incorrect (6+ type treatments creating visual noise):**

```swift
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("FEATURED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)

                Text(product.name)
                    .font(.title)
                    .fontWeight(.heavy)

                Text(product.subtitle)
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)

                Text(product.price)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)

                Text(product.description)
                    .font(.body)

                Text("Free shipping on orders over $50")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)

                Text("In stock · Ships in 2-3 days")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

**Correct (3 clear type levels — title, body, caption):**

```swift
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Level 1: Title
                Text(product.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Level 2: Body
                Text(product.price)
                    .font(.title3)

                Text(product.description)
                    .font(.body)

                // Level 3: Supporting
                Text("Free shipping on orders over $50")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("In stock · Ships in 2-3 days")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

**How to audit an existing screen:**
1. Screenshot the screen and squint — if you cannot instantly identify the 2-3 most important elements, the hierarchy is too flat.
2. List every unique font/weight/color combination. If the count exceeds 4, merge the lowest-priority levels.
3. Ask: "Can a user scan this screen in under 2 seconds and know what action to take?" If not, reduce type treatments.

**When NOT to apply:**
- Data-dense screens (e.g., a stock trading dashboard) may legitimately need 5 levels to distinguish ticker, price, change, volume, and timestamp. In these cases, reinforce hierarchy with spatial grouping and color rather than adding more type treatments.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
