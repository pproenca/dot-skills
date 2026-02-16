---
title: Enforce Consistent Naming Conventions Across All Tokens
impact: HIGH
impactDescription: reduces token lookup time by 2-5× — consistent lowerCamelCase naming enables predictable autocomplete across all token domains
tags: govern, naming, conventions, discoverability, airbnb
---

## Enforce Consistent Naming Conventions Across All Tokens

A design system is an API. Its naming conventions determine how fast developers find the right token. Airbnb's Swift Style Guide mandates lowerCamelCase for all properties and PascalCase for types. Design tokens must follow the same conventions: `backgroundPrimary` not `background_primary`, `IconSize` not `iconSize` for the enum, `Spacing.md` not `Spacing.medium`. Consistency across token domains means learning one naming pattern unlocks all of them.

**Incorrect (inconsistent naming across token domains):**

```swift
// Colors: mixed naming strategies
extension ShapeStyle where Self == Color {
    static var bg_primary: Color { Color("bg_primary") }        // snake_case
    static var TextPrimary: Color { Color("TextPrimary") }      // PascalCase
    static var accent_primary: Color { Color("accent-primary") } // kebab in catalog
}

// Spacing: verbose names
enum Spacing {
    static let smallSpacing: CGFloat = 8     // Redundant "Spacing" suffix
    static let medium_spacing: CGFloat = 16  // snake_case
    static let LARGE: CGFloat = 24           // SCREAMING_CASE
}

// Sizes: no consistent prefix pattern
enum Sizes {
    static let avatarSmall: CGFloat = 32
    static let sm_icon: CGFloat = 16
    static let LargeButton: CGFloat = 48
}
```

**Correct (uniform lowerCamelCase, consistent scale names):**

```swift
// Colors: lowerCamelCase, role-based naming
extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var textPrimary: Color { Color("textPrimary") }
    static var accentPrimary: Color { Color("accentPrimary") }
    static var statusSuccess: Color { Color("statusSuccess") }
}

// Spacing: t-shirt sizes, no domain suffix
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// Sizes: PascalCase enum, lowerCamelCase t-shirt sizes
enum IconSize {
    static let sm: CGFloat = 16
    static let md: CGFloat = 24
    static let lg: CGFloat = 32
}

enum AvatarSize {
    static let sm: CGFloat = 32
    static let md: CGFloat = 44
    static let lg: CGFloat = 64
}
```

**Naming convention reference:**

| Domain | Type Name | Property Names | Examples |
|--------|-----------|----------------|----------|
| Colors | `ShapeStyle extension` | `roleContext` (lowerCamelCase) | `.backgroundPrimary`, `.statusError` |
| Spacing | `enum Spacing` | `xxs/xs/sm/md/lg/xl/xxl` | `Spacing.md` |
| Radius | `enum Radius` | `sm/md/lg/full` | `Radius.md` |
| Icons | `enum IconSize` | `sm/md/lg/xl` | `IconSize.md` |
| Avatars | `enum AvatarSize` | `sm/md/lg/xl` | `AvatarSize.lg` |
| Typography | `enum AppTypography` | `rolePrimary/roleSecondary` | `AppTypography.headlinePrimary` |
| Asset catalog | — | `lowerCamelCase` for colors, `kebab-case` for images | `backgroundPrimary`, `onboarding-hero` |

**Benefits:**
- Xcode autocomplete becomes predictable: type `background` and see all background tokens
- New developers learn one naming pattern that applies to every token domain
- Code review catches violations instantly: any `snake_case` or `SCREAMING_CASE` in tokens is wrong

Reference: [Airbnb Swift Style Guide](https://github.com/airbnb/swift), [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
