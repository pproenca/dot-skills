---
title: "Use a Three-Layer Token Hierarchy: Raw to Semantic to Component"
impact: CRITICAL
impactDescription: eliminates 100% of scattered values and survives rebrands with 1-file change instead of 50+
tags: token, architecture, design-system, hierarchy, maintainability
---

## Use a Three-Layer Token Hierarchy: Raw to Semantic to Component

Scattered values scattered across a codebase are impossible to audit, update, or keep consistent. A three-layer token hierarchy solves this by separating the actual value from its meaning from its usage context. Raw tokens hold the literal values and are never referenced by views. Semantic tokens describe purpose and are the primary API for view code. Component tokens exist only when a complex shared component needs its own vocabulary. During a rebrand, you change raw token values, semantic mappings update automatically, and zero view code changes.

**Incorrect (views reference raw values directly):**

```swift
struct ProfileHeader: View {
    let displayName: String
    let memberSince: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            Text("Member since \(memberSince)")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "#8E8E93"))
        }
        .padding(16)
        .background(Color(hex: "#F2F2F7"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Correct (three-layer token system):**

```swift
// MARK: - Layer 1: Raw Tokens (private, never used in views)
enum RawColor {
    static let ink900 = Color("ink900")      // #1A1A2E — sourced from asset catalog
    static let ink400 = Color("ink400")      // #8E8E93
    static let cloud50 = Color("cloud50")    // #F2F2F7
    static let brand500 = Color("brand500")  // #5856D6
}

enum RawSize {
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s16: CGFloat = 16
    static let s24: CGFloat = 24
}

// MARK: - Layer 2: Semantic Tokens (the public API for views)
extension ShapeStyle where Self == Color {
    static var textPrimary: Color { RawColor.ink900 }
    static var textSecondary: Color { RawColor.ink400 }
    static var backgroundSurface: Color { RawColor.cloud50 }
    static var accentPrimary: Color { RawColor.brand500 }
}

enum Spacing {
    static let xs: CGFloat = RawSize.s4
    static let sm: CGFloat = RawSize.s8
    static let md: CGFloat = RawSize.s16
    static let lg: CGFloat = RawSize.s24
}
```

```swift
// MARK: - Layer 3: Component Tokens (only for complex shared components)
enum ProfileCardTokens {
    static let avatarSize: CGFloat = 48
    static let contentSpacing: CGFloat = Spacing.sm
    static let containerPadding: CGFloat = Spacing.md
    static let cornerRadius: CGFloat = Radius.md
}

// MARK: - View uses semantic tokens
@Equatable
struct ProfileHeader: View {
    let displayName: String
    let memberSince: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(displayName)
                .font(.headline)
                .foregroundStyle(.textPrimary)
            Text("Member since \(memberSince)")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
        .padding(Spacing.md)
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
```

**When to use each layer:**
| Layer | Audience | Stability | Example |
|---|---|---|---|
| Raw | Token authors only | Changes with rebrand | `RawColor.blue500` |
| Semantic | All view code | Stable across rebrands | `.textPrimary`, `Spacing.md` |
| Component | Complex shared components | Stable across rebrands | `ButtonTokens.paddingHorizontal` |

**Benefits:**
- Rebrand = change raw token values. Semantic names stay the same, views never change
- New developers search for `.textPrimary` and instantly find the color definition
- Code review catches violations easily: any `Color(hex:)` or literal `CGFloat` in a view is a red flag
- Layer 3 is optional — most apps only need raw + semantic

Reference: [Design Tokens W3C Community Group](https://design-tokens.github.io/community-group/format/), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
