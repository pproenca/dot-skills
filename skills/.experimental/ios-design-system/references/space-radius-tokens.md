---
title: Define Corner Radius Tokens by Component Type
impact: HIGH
impactDescription: reduces corner radius variations from N ad-hoc values to 3-4 governed tokens — eliminates per-component radius debates in code review
tags: space, radius, corner-radius, consistency, tokens
---

## Define Corner Radius Tokens by Component Type

Corner radius is one of the most visible brand signals in an app. When every component picks a slightly different radius — 8pt here, 10pt there, 12pt on another — the result feels unfinished. Defining 3-4 radius tokens grouped by component scale creates visual consistency and eliminates bike-shedding in code review.

**Incorrect (inconsistent radii with no system):**

```swift
// SearchBar.swift
.clipShape(RoundedRectangle(cornerRadius: 10))

// ProductCard.swift
.clipShape(RoundedRectangle(cornerRadius: 12))

// ActionButton.swift
.clipShape(RoundedRectangle(cornerRadius: 8))

// BottomSheet.swift
.clipShape(RoundedRectangle(cornerRadius: 16))

// TagChip.swift
.clipShape(RoundedRectangle(cornerRadius: 6))

// UserAvatar.swift
.clipShape(RoundedRectangle(cornerRadius: 22))

// Six different radii — no visual system.
// "Should this new tooltip be 8 or 10?" becomes a recurring debate.
```

**Correct (3-4 radius tokens mapped to component scale):**

```swift
// DesignSystem/Tokens/Radius.swift
enum Radius {
    /// 8pt — small elements: chips, tags, badges, tooltips, text fields
    static let sm: CGFloat = 8

    /// 12pt — medium elements: cards, buttons, list rows, search bars
    static let md: CGFloat = 12

    /// 20pt — large containers: sheets, modals, popovers, action sheets
    static let lg: CGFloat = 20

    /// Fully rounded — pills, avatars, circular buttons, toggles
    static let full: CGFloat = .infinity
}

// Usage:
struct ProductCard: View {
    var body: some View {
        VStack { /* ... */ }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

struct TagChip: View {
    var body: some View {
        Text(tag.name)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(.fill.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

struct UserAvatar: View {
    var body: some View {
        image
            .clipShape(RoundedRectangle(cornerRadius: Radius.full))
    }
}
```

**Convenience shapes for repeated use:**

```swift
extension RoundedRectangle {
    static let cardShape = RoundedRectangle(cornerRadius: Radius.md)
    static let chipShape = RoundedRectangle(cornerRadius: Radius.sm)
    static let sheetShape = RoundedRectangle(cornerRadius: Radius.lg)
}

// Cleaner callsites:
.clipShape(.cardShape)
.clipShape(.chipShape)
```

**How to decide which token a new component gets:**

| Component Scale | Token | Examples |
|----------------|-------|----------|
| Small (< 44pt height) | `.sm` | Chips, badges, tags, tooltips |
| Medium (44-200pt) | `.md` | Cards, buttons, inputs, cells |
| Large (> 200pt) | `.lg` | Sheets, modals, full-width containers |
| Circular | `.full` | Avatars, FABs, status indicators |

If a new component doesn't clearly fit, pick the closest scale. Never introduce a fifth radius value.
