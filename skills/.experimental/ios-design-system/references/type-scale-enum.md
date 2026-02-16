---
title: Define a Type Scale Enum Wrapping System Styles
impact: HIGH
impactDescription: a centralized type scale prevents 20+ scattered .font(.system(size:)) calls and ensures Dynamic Type works everywhere
tags: type, typography, scale, dynamic-type, enum
---

## Define a Type Scale Enum Wrapping System Styles

A type scale enum gives the entire codebase a single vocabulary for typography. Without one, developers pick arbitrary sizes and weights per view, creating visual inconsistency that compounds with every new screen. Centralizing also makes a brand-wide typography refresh a single-file change instead of a multi-day grep-and-replace.

**Incorrect (ad-hoc sizes scattered across views):**

```swift
// ProfileHeaderView.swift
Text(user.name)
    .font(.system(size: 28, weight: .bold))

// SettingsRowView.swift
Text(setting.title)
    .font(.system(size: 16, weight: .medium))

// TransactionCell.swift
Text(amount)
    .font(.system(size: 14, weight: .semibold))

// 30+ views each with their own size/weight combos
// No Dynamic Type support, no single source of truth
```

**Correct (centralized type scale wrapping system styles):**

```swift
enum AppTypography {
    // Display — hero areas, onboarding, empty states
    static let displayLarge: Font = .largeTitle.weight(.bold)
    static let displayMedium: Font = .title.weight(.semibold)

    // Headlines — section headers, card titles
    static let headlinePrimary: Font = .headline
    static let headlineSecondary: Font = .subheadline.weight(.semibold)

    // Body — primary content
    static let bodyPrimary: Font = .body
    static let bodySecondary: Font = .callout

    // Supporting — metadata, timestamps, labels
    static let caption: Font = .caption
    static let captionSecondary: Font = .caption2

    // Specialized — tabular data, codes
    static let monoBody: Font = .body.monospaced()
}

// Usage across the app:
Text(user.name)
    .font(AppTypography.headlinePrimary)

Text(setting.title)
    .font(AppTypography.bodyPrimary)

Text(transaction.amount)
    .font(AppTypography.headlineSecondary)
```

The type scale should have at most 8-10 entries. If you need more, the design likely has too many typographic treatments. Every entry wraps a system text style, so Dynamic Type scaling is automatic.
