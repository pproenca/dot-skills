---
title: Use Semantic Colors, Never Hard-Coded Values
impact: CRITICAL
impactDescription: hard-coded Color.black and Color.white break in Dark Mode for 100% of users who toggle appearance — text becomes invisible and backgrounds blind the user in low-light environments
tags: empathy, color, semantic, kocienda-empathy, edson-people, dark-mode
---

## Use Semantic Colors, Never Hard-Coded Values

Kocienda writes that empathy means "trying to see the world from other people's perspectives." A developer who hard-codes `Color.black` has only seen the app in light mode on their desk. The user reading in bed at midnight with Dark Mode enabled sees invisible text on a glaring background. Edson's foundational principle — design is about people — demands that color decisions serve every context the user inhabits, not just the developer's preview canvas. A semantic color like `.primary` tells the truth: "this is important text," and SwiftUI translates that role into the appropriate color for every appearance, accessibility setting, and contrast mode.

**Incorrect (hard-coded colors that ignore appearance):**

```swift
struct SettingsRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(Color.black)

                Text(subtitle)
                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color(red: 0.8, green: 0.8, blue: 0.8))
        }
        .padding()
        .background(Color.white)
    }
}
```

**Correct (semantic colors that adapt to every appearance):**

```swift
struct SettingsRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
```

**Semantic color mapping cheat sheet:**
- `Color.black` → `.primary` (adapts to white in Dark Mode)
- `Color.white` → `Color(.systemBackground)` (adapts to near-black in Dark Mode)
- `Color(red:green:blue:)` gray → `.secondary` or `.tertiary` (pre-validated for both modes)
- Light gray background → `Color(.secondarySystemBackground)` (grouped table style)
- `Color(.separator)` for dividers instead of `Color.gray.opacity(0.3)`

**When NOT to use semantic colors:** Decorative illustrations, brand logos, and photography where the exact color is part of the content itself. Even then, test in both appearances.

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [UI Element Colors - UIKit](https://developer.apple.com/documentation/uikit/uicolor/ui_element_colors)
