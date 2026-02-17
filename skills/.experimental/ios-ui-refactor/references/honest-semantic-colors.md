---
title: Use Semantic Colors, Never Hard-Coded Black or White
impact: CRITICAL
impactDescription: hard-coded Color.black and Color.white break in dark mode for 100% of users who toggle appearance — text becomes invisible and backgrounds blind the user in low-light environments
tags: honest, color, semantic, rams-6, segall-brutal, dark-mode
---

## Use Semantic Colors, Never Hard-Coded Black or White

`Color.black` in dark mode is a lie: the interface claims to show text but renders invisible content — black glyphs on a near-black background, swallowed whole. It promises readability in every context but delivers blindness at nightfall. The problem is not the color itself but the false certainty it carries: black is not "dark text," it is a literal absence of light that never adapts, never defers, never asks the system what the user actually needs. A semantic color like `.primary` tells the truth instead — it says "this is important text" and lets SwiftUI translate that role into the right color for every appearance, accessibility setting, and contrast mode. The craft difference is between a value that looks correct on your monitor and a role that remains correct everywhere the interface travels.

**Incorrect (hard-coded color values that ignore appearance):**

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
- `Color.black` → `.primary` (adapts to white in dark mode)
- `Color.white` → `Color(.systemBackground)` (adapts to near-black in dark mode)
- `Color(red:green:blue:)` gray → `.secondary` or `.tertiary` (pre-validated for both modes)
- Light gray background → `Color(.secondarySystemBackground)` (grouped table style)
- `Color(.separator)` for dividers instead of `Color.gray.opacity(0.3)`

**When NOT to apply:** Decorative illustrations, brand logos, and photography where the exact color is part of the content itself. Even then, test in both appearances.

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [UI Element Colors - UIKit](https://developer.apple.com/documentation/uikit/uicolor/ui_element_colors)
