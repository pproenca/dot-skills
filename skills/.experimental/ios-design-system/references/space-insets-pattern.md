---
title: Use EdgeInsets Constants for Composite Padding
impact: HIGH
impactDescription: EdgeInsets constants make padding intention explicit and prevent the common mistake of inconsistent top/bottom vs leading/trailing values
tags: space, edge-insets, padding, composition, reuse
---

## Use EdgeInsets Constants for Composite Padding

When a component needs asymmetric padding (different horizontal vs vertical, or different top vs bottom), chaining multiple `.padding()` calls obscures the intent and invites drift. One developer writes `.padding(.horizontal, 16).padding(.vertical, 12)`, another writes `.padding(.top, 12).padding(.bottom, 16).padding(.horizontal, 16)` — both for the same component type. EdgeInsets constants encode the full padding as a single named value that's reusable and auditable.

**Incorrect (chained padding calls that drift):**

```swift
// ProductCard.swift — original padding
VStack { /* ... */ }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)

// ProductCard in SearchResults.swift — copy-pasted, then tweaked
VStack { /* ... */ }
    .padding(.horizontal, 16)
    .padding(.top, 12)
    .padding(.bottom, 16) // "needed more room for the price"

// ProductCard in FavoritesView.swift — yet another variant
VStack { /* ... */ }
    .padding(16) // "close enough"

// Three cards, three different internal paddings. No consistency.
```

**Correct (EdgeInsets constants with clear naming):**

```swift
// DesignSystem/Tokens/Insets.swift
extension EdgeInsets {
    // Card content — standard internal padding for card-style containers
    static let cardContent = EdgeInsets(
        top: Spacing.sm,
        leading: Spacing.md,
        bottom: Spacing.sm,
        trailing: Spacing.md
    )

    // List cell — matches UIKit default cell padding
    static let listCell = EdgeInsets(
        top: Spacing.sm,
        leading: Spacing.md,
        bottom: Spacing.sm,
        trailing: Spacing.md
    )

    // Section content — breathing room for section-level containers
    static let sectionContent = EdgeInsets(
        top: Spacing.md,
        leading: Spacing.md,
        bottom: Spacing.md,
        trailing: Spacing.md
    )

    // Screen content — outermost content padding
    static let screenContent = EdgeInsets(
        top: Spacing.md,
        leading: Spacing.md,
        bottom: Spacing.lg,
        trailing: Spacing.md
    )

    // Banner — taller top/bottom for promotional areas
    static let banner = EdgeInsets(
        top: Spacing.lg,
        leading: Spacing.md,
        bottom: Spacing.lg,
        trailing: Spacing.md
    )
}
```

**Usage in views:**

```swift
// Every ProductCard now has identical padding, guaranteed:
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ProductImage(url: product.imageURL)
            Text(product.name)
                .font(AppTypography.headlinePrimary)
            Text(product.price, format: .currency(code: "GBP"))
                .font(AppTypography.bodySecondary)
                .foregroundStyle(.secondary)
        }
        .padding(.cardContent) // Single call, full intent
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// Screen-level padding applied once:
struct ProductListScreen: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
            .padding(.screenContent)
        }
    }
}
```

**Asymmetric insets for specific contexts:**

```swift
extension EdgeInsets {
    // Form field — extra bottom padding for error message space
    static let formField = EdgeInsets(
        top: Spacing.sm,
        leading: Spacing.md,
        bottom: Spacing.md, // Room for validation error below
        trailing: Spacing.md
    )

    // Navigation header — more top, tight bottom
    static let navigationHeader = EdgeInsets(
        top: Spacing.lg,
        leading: Spacing.md,
        bottom: Spacing.sm,
        trailing: Spacing.md
    )
}
```

EdgeInsets constants work with the `.padding(_:)` overload that accepts `EdgeInsets` directly — no chaining needed.
