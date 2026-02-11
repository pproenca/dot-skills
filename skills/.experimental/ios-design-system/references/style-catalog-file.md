---
title: Maintain a Single Style Catalog File Per Component Type
impact: HIGH
impactDescription: centralizing all ButtonStyles in ButtonStyles.swift makes the full palette discoverable — scattered style definitions across feature modules create invisible duplicates
tags: style, catalog, organization, discoverability, file-structure
---

## Maintain a Single Style Catalog File Per Component Type

When styles are defined inline with feature code, the design system becomes invisible. A developer building a new screen doesn't know that `PrimaryButtonStyle` already exists in `ProfileView.swift`, so they create `BrandButtonStyle` in `CheckoutView.swift` — same visual, different name. Centralizing all styles for a component type in one file makes the full palette discoverable, prevents duplication, and enables side-by-side comparison.

**Incorrect (styles scattered across feature modules):**

```text
Features/
├── Profile/
│   ├── ProfileView.swift
│   └── PrimaryButtonStyle.swift     // Defined here
├── Settings/
│   ├── SettingsView.swift
│   └── SecondaryButtonStyle.swift   // Defined here
├── Checkout/
│   ├── CheckoutView.swift
│   └── OutlinedButtonStyle.swift    // And here
└── Onboarding/
    ├── OnboardingView.swift
    └── LargeActionButtonStyle.swift // Duplicate of PrimaryButtonStyle?

// Problems:
// 1. No one knows how many ButtonStyles exist
// 2. LargeActionButtonStyle is likely a duplicate
// 3. Comparing styles requires opening 4 files
// 4. Static member extensions scattered or missing
```

**Correct (one file per component type in the design system module):**

```text
DesignSystem/
├── Tokens/
│   ├── Spacing.swift
│   ├── Radius.swift
│   ├── Size.swift
│   └── Insets.swift
├── Typography/
│   ├── AppTypography.swift
│   └── AppFont.swift
├── Colors/
│   └── Colors.xcassets
├── Styles/
│   ├── ButtonStyles.swift          // ALL button styles
│   ├── TextFieldStyles.swift       // ALL text field styles
│   ├── ToggleStyles.swift          // ALL toggle styles
│   ├── LabelStyles.swift           // ALL label styles
│   └── CardStyles.swift            // ALL card view modifiers
└── Modifiers/
    ├── ShimmerModifier.swift
    └── BadgeModifier.swift
```

**What a style catalog file looks like:**

```swift
// DesignSystem/Styles/ButtonStyles.swift

import SwiftUI

// MARK: - Primary

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? .accentPrimary : .fill.tertiary)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - Secondary

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(.accentPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(.accentPrimary.opacity(0.12))
            .clipShape(Capsule())
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1.0) : 0.4)
    }
}

// MARK: - Outlined

struct OutlinedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(isEnabled ? .accentPrimary : .secondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .overlay {
                Capsule()
                    .strokeBorder(isEnabled ? .accentPrimary : .secondary, lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - Destructive

struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? .red : .fill.tertiary)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - Static Member Extensions

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { .init() }
}

extension ButtonStyle where Self == OutlinedButtonStyle {
    static var outlined: OutlinedButtonStyle { .init() }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { .init() }
}
```

**Naming convention:**

| Component Type | File Name | Style Naming |
|---------------|-----------|-------------|
| Button | `ButtonStyles.swift` | `PrimaryButtonStyle`, `.primary` |
| TextField | `TextFieldStyles.swift` | `FormTextFieldStyle`, `.form` |
| Toggle | `ToggleStyles.swift` | `CheckboxToggleStyle`, `.checkbox` |
| Label | `LabelStyles.swift` | `SubtitleLabelStyle`, `.subtitle` |

Keep the style struct, its static member extension, and any supporting types (like configuration enums) in the same file. One file = complete story for that component type.
