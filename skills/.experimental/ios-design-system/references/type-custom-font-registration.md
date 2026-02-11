---
title: Register Custom Fonts Once with a Centralized Extension
impact: HIGH
impactDescription: scattered Font.custom() calls with hardcoded font names break when fonts are renamed or replaced — a single extension makes font changes a 1-line fix
tags: type, custom-font, registration, maintenance, Font
---

## Register Custom Fonts Once with a Centralized Extension

When an app uses a custom typeface (Inter, Poppins, SF Pro Rounded via custom weight mapping, etc.), the font family name and weight-to-filename mapping must live in exactly one place. Hardcoding `Font.custom("Inter-SemiBold", size: 16)` across dozens of views means a font rename or license change requires updating every callsite. Worse, using the `size:` parameter instead of `relativeTo:` kills Dynamic Type scaling.

**Incorrect (hardcoded font names, fixed sizes):**

```swift
// ProfileView.swift
Text(user.name)
    .font(.custom("Inter-Bold", size: 24))

// SettingsView.swift
Text(setting.title)
    .font(.custom("Inter-Medium", size: 16))

// TransactionView.swift
Text(amount)
    .font(.custom("Inter-SemiBold", size: 14))

// Problems:
// 1. "Inter-Bold" string repeated in 40+ places
// 2. Fixed `size:` — no Dynamic Type scaling
// 3. Renaming to "InterDisplay-Bold" requires find-and-replace across entire project
```

**Correct (centralized extension with Dynamic Type):**

```swift
// Typography/AppFont.swift
extension Font {
    /// Creates an app font that scales with Dynamic Type.
    /// - Parameters:
    ///   - style: The text style to scale relative to.
    ///   - weight: The font weight. Defaults to `.regular`.
    static func app(
        _ style: Font.TextStyle,
        weight: Font.Weight = .regular
    ) -> Font {
        .custom(fontName(for: weight), relativeTo: style)
    }

    private static func fontName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black: "Inter-Bold"
        case .semibold:             "Inter-SemiBold"
        case .medium:               "Inter-Medium"
        case .light, .ultraLight:   "Inter-Light"
        default:                    "Inter-Regular"
        }
    }
}

// Then the type scale references this:
enum AppTypography {
    static let displayLarge: Font = .app(.largeTitle, weight: .bold)
    static let headlinePrimary: Font = .app(.headline, weight: .semibold)
    static let bodyPrimary: Font = .app(.body)
    static let caption: Font = .app(.caption)
}

// Usage — clean, scalable, single source of truth:
Text(user.name)
    .font(AppTypography.displayLarge)
```

**Switching to a new typeface becomes trivial:**

```swift
// Before: Inter
private static func fontName(for weight: Font.Weight) -> String {
    switch weight {
    case .bold, .heavy, .black: "Inter-Bold"
    // ...
    }
}

// After: Instrument Sans — change ONE function
private static func fontName(for weight: Font.Weight) -> String {
    switch weight {
    case .bold, .heavy, .black: "InstrumentSans-Bold"
    case .semibold:             "InstrumentSans-SemiBold"
    case .medium:               "InstrumentSans-Medium"
    default:                    "InstrumentSans-Regular"
    }
}
// Every view in the app now uses the new font. Zero other changes needed.
```

Always use `relativeTo:` (not `size:`) to preserve Dynamic Type scaling with custom fonts.
