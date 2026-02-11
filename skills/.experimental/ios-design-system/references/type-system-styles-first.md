---
title: Use System Text Styles Before Creating Custom Ones
impact: HIGH
impactDescription: system text styles (.title, .body, .caption) scale with Dynamic Type automatically — custom Font.system(size:) breaks accessibility for 25% of iOS users who change text size
tags: type, system-styles, dynamic-type, accessibility
---

## Use System Text Styles Before Creating Custom Ones

Apple provides 11 text styles that cover virtually every typographic need in an app. These styles respond to the user's Dynamic Type preference automatically. When you bypass them with `Font.system(size:)`, text becomes fixed — unreadable for users who need larger text and wastefully large for users who prefer compact layouts. Before adding a custom entry to your type scale, verify that no system style with a weight modifier already matches.

**Incorrect (custom size when a system style exists):**

```swift
// Developer wants a "section title" — creates a custom size
enum AppTypography {
    // This is just .title3 with extra steps, and it won't scale
    static let sectionTitle = Font.system(size: 20, weight: .semibold)

    // This is .footnote but fixed
    static let metadataLabel = Font.system(size: 13, weight: .regular)

    // This is .caption2 but won't respond to Dynamic Type
    static let timestamp = Font.system(size: 11, weight: .regular)
}
```

**Correct (system styles first, custom only when truly needed):**

```swift
enum AppTypography {
    // Maps directly to system styles — full Dynamic Type support
    static let sectionTitle: Font = .title3.weight(.semibold)
    static let metadataLabel: Font = .footnote
    static let timestamp: Font = .caption2

    // Custom entry — justified because the design requires a specific
    // weight/width combo that no system style provides
    static let priceDisplay: Font = .system(
        .title,
        design: .rounded,
        weight: .heavy
    )
    // Still uses .title as the base, so Dynamic Type works
}
```

**The 11 system text styles (from largest to smallest):**

| Style | Typical Use |
|-------|-------------|
| `.largeTitle` | Navigation bar large titles |
| `.title` | Primary screen titles |
| `.title2` | Secondary titles |
| `.title3` | Tertiary titles, section headers |
| `.headline` | Emphasized body text, row labels |
| `.subheadline` | Supporting text below headlines |
| `.body` | Primary content text |
| `.callout` | Secondary content, explanations |
| `.footnote` | Footer text, form labels |
| `.caption` | Metadata, timestamps |
| `.caption2` | Smallest text, legal, badges |

If your design spec says "20pt semibold", look up which system style is closest (`.title3`), apply the weight modifier, and document the mapping. Only create a truly custom font entry when no system style with modifiers can match.
