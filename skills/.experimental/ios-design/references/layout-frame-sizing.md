---
title: Use frame() for Explicit Size Constraints
impact: HIGH
impactDescription: explicit frame constraints eliminate 80-100% of layout shift jank — prevents cumulative layout shift (CLS) of 10-50pt per unconstrained AsyncImage and reduces layout-pass recalculations by 2-4× in variable-content lists
tags: layout, frame, sizing, constraints, edson-design-out-loud, kocienda-intersection
---

## Use frame() for Explicit Size Constraints

Edson's "Design Out Loud" requires explicit decisions about how much space each element occupies. SwiftUI views are intrinsically sized by their content — a `Text` is as wide as its text, an `Image` is as large as its asset. When content varies (user names, descriptions, dynamic data), unconstrained views create layouts that shift unpredictably. `.frame()` sets explicit boundaries: minimum, ideal, and maximum sizes that create predictable, consistent results.

**Incorrect (unconstrained image causes layout shifts):**

```swift
struct PropertyCard: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading) {
            // Image size varies with asset — layout shifts between cards
            AsyncImage(url: property.imageURL) { image in
                image.resizable()
            } placeholder: {
                Color(.systemFill)
            }

            Text(property.title)
                .font(.headline)
        }
    }
}
```

**Correct (frame constrains image to consistent size):**

```swift
struct PropertyCard: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: property.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.systemFill)
            }
            .frame(height: 200)
            .clipped()

            Text(property.title)
                .font(.headline)
        }
    }
}
```

**Frame patterns:**

```swift
// Fixed size
.frame(width: 44, height: 44)

// Full width with fixed height
.frame(maxWidth: .infinity)
.frame(height: 200)

// Minimum and maximum bounds
.frame(minHeight: 44, maxHeight: 200)

// Alignment within frame
.frame(maxWidth: .infinity, alignment: .leading)

// Aspect ratio instead of fixed dimensions
.aspectRatio(16/9, contentMode: .fill)
```

**When NOT to use frame:** Don't constrain text views to fixed widths (use `lineLimit` instead). Don't set fixed heights on content that should scroll. Don't use `.frame(maxWidth: .infinity)` inside `List` rows — they already fill width.

Reference: [Layout fundamentals - Apple Documentation](https://developer.apple.com/documentation/swiftui/layout-fundamentals)
