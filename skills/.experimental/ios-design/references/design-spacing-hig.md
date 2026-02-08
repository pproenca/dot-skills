---
title: Use HIG-Compliant Spacing Values
impact: CRITICAL
impactDescription: creates visual rhythm matching Apple's native apps
tags: design, spacing, padding, margins, hig
---

## Use HIG-Compliant Spacing Values

Apple uses an 8-point grid system. Spacing values should be multiples of 4 or 8 points. Random values create visual discord.

**Incorrect (arbitrary spacing values):**

```swift
struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .padding(.horizontal, 15)  // Arbitrary value
        .padding(.vertical, 11)    // Not on grid
    }
}
```

**Correct (8-point grid):**

```swift
struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)  // 2 x 8
        .padding(.vertical, 12)    // 1.5 x 8
    }
}
```

**Standard spacing constants:**

```swift
enum Spacing {
    static let xxs: CGFloat = 4   // Tight grouping
    static let xs: CGFloat = 8    // Related elements
    static let sm: CGFloat = 12   // Standard gap
    static let md: CGFloat = 16   // Section padding
    static let lg: CGFloat = 24   // Major sections
    static let xl: CGFloat = 32   // Screen margins
    static let xxl: CGFloat = 48  // Hero spacing
}

// Usage
VStack(spacing: Spacing.sm) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
.padding(Spacing.md)
```

**Note:** iOS uses 16pt horizontal margins for content and 20pt for grouped table views.

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
