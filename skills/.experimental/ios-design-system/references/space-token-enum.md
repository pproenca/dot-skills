---
title: Define Spacing Tokens as a Caseless Enum
impact: HIGH
impactDescription: replaces 100+ magic numbers (.padding(16), .spacing(8)) with named constants (.padding(.md)) that can be updated globally
tags: space, tokens, enum, magic-numbers, consistency
---

## Define Spacing Tokens as a Caseless Enum

Magic numbers are the most common design system violation. Every `.padding(16)` is a decision that future developers must reverse-engineer: is 16 the standard card padding, or was it a one-off choice? A spacing token enum answers that question by name and makes global spacing adjustments a single-file change. Apple internally uses a 4pt base grid, and your tokens should follow the same principle.

**Incorrect (magic numbers with no system):**

```swift
struct OrderSummaryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text(order.title)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Divider()
                .padding(.horizontal, 16) // Wait, why 16 here but 20 above?

            ForEach(order.items) { item in
                ItemRow(item: item)
                    .padding(.horizontal, 20) // Back to 20
                    .padding(.vertical, 8)
            }

            TotalRow(total: order.total)
                .padding(24) // And now 24?
        }
        // Four different spacing values in one view.
        // Which is intentional? Which is a typo?
    }
}
```

**Correct (spacing tokens with clear intent):**

```swift
// DesignSystem/Tokens/Spacing.swift
enum Spacing {
    /// 2pt — hairline separations, icon-to-label tight pairs
    static let xxs: CGFloat = 2

    /// 4pt — compact element gaps, inline icon spacing
    static let xs: CGFloat = 4

    /// 8pt — standard element spacing within a group
    static let sm: CGFloat = 8

    /// 16pt — standard content padding, section spacing
    static let md: CGFloat = 16

    /// 24pt — spacing between distinct sections
    static let lg: CGFloat = 24

    /// 32pt — major section breaks, screen-level spacing
    static let xl: CGFloat = 32

    /// 48pt — hero spacing, visual breathing room
    static let xxl: CGFloat = 48
}

// Usage — clear intent, globally adjustable:
struct OrderSummaryView: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(order.title)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

            Divider()
                .padding(.horizontal, Spacing.md)

            ForEach(order.items) { item in
                ItemRow(item: item)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
            }

            TotalRow(total: order.total)
                .padding(Spacing.lg)
        }
    }
}
```

**Why a caseless enum (not a struct)?**

```swift
// Caseless enum cannot be instantiated — it's a pure namespace
enum Spacing {
    static let md: CGFloat = 16
}

// Struct CAN be instantiated — confusing, adds nothing
struct Spacing {
    static let md: CGFloat = 16
}
let _ = Spacing() // Compiles but is meaningless
```

**Scale progression options:**

```text
// Geometric (multiply by 2): 4, 8, 16, 32, 64
// Good for: clear visual jumps between levels

// Arithmetic (add 8):        8, 16, 24, 32, 40
// Good for: gradual, subtle progression

// Hybrid (Apple-like):       2, 4, 8, 16, 24, 32, 48
// Good for: practical flexibility at every scale
```

The hybrid scale works best for most apps because it provides tight spacing at small sizes (2, 4, 8) and comfortable jumps at larger sizes (16, 24, 32, 48).
