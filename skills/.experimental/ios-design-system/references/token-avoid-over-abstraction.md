---
title: Avoid Over-Abstracting Tokens Beyond Three Layers
impact: CRITICAL
impactDescription: each additional indirection layer adds cognitive load without proportional benefit — apps with 4+ layers spend more time maintaining tokens than building features
tags: token, pragmatism, over-engineering, maintainability
---

## Avoid Over-Abstracting Tokens Beyond Three Layers

Token hierarchies follow the law of diminishing returns. The jump from zero layers (magic values) to two layers (raw + semantic) eliminates most maintenance pain. The optional third layer (component tokens) helps complex shared components. Beyond that, each additional layer — alias tokens, theme tokens, platform tokens, variant tokens — adds indirection that slows down every developer who needs to trace a value back to its source. Apple's own apps use at most two explicit layers. The web design system community's deep token hierarchies do not translate to iOS, where the asset catalog already handles multi-appearance resolution.

**Incorrect (5 layers of indirection):**

```swift
// Layer 1: Primitives
enum Primitive {
    enum Color {
        static let blue500 = SwiftUI.Color(hex: "#5856D6")
        static let blue600 = SwiftUI.Color(hex: "#4240B0")
    }
}

// Layer 2: Platform tokens (unnecessary on single-platform)
enum PlatformToken {
    enum Color {
        static let interactiveBase = Primitive.Color.blue500
        static let interactivePressed = Primitive.Color.blue600
    }
}

// Layer 3: Alias tokens (adds confusion, not clarity)
enum AliasToken {
    enum Color {
        static let actionDefault = PlatformToken.Color.interactiveBase
        static let actionActive = PlatformToken.Color.interactivePressed
    }
}

// Layer 4: Semantic tokens
enum SemanticToken {
    enum Button {
        static let backgroundDefault = AliasToken.Color.actionDefault
        static let backgroundPressed = AliasToken.Color.actionActive
    }
}

// Layer 5: Component tokens
enum PrimaryButtonToken {
    static let background = SemanticToken.Button.backgroundDefault
    static let backgroundPressed = SemanticToken.Button.backgroundPressed
}

// Developer trying to find the actual color value:
// PrimaryButtonToken.background
//   → SemanticToken.Button.backgroundDefault
//     → AliasToken.Color.actionDefault
//       → PlatformToken.Color.interactiveBase
//         → Primitive.Color.blue500
//           → "#5856D6"
// Six jumps to find a hex value.
```

**Correct (two layers for most apps, three for complex components):**

```swift
// Layer 1: Raw values live in the asset catalog (Colors.xcassets)
// No raw token enum needed — the asset catalog IS the raw layer

// Layer 2: Semantic tokens (the only layer most views need)
extension ShapeStyle where Self == Color {
    static var accentPrimary: Color { Color("accentPrimary") }
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusError: Color { Color("statusError") }
    static var borderDefault: Color { Color("borderDefault") }
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// Layer 3: Component tokens ONLY for complex shared components
// (e.g., a navigation bar, a complex card, a custom tab bar)
enum SearchBarTokens {
    static let height: CGFloat = 36
    static let horizontalPadding: CGFloat = Spacing.sm
    static let iconSize: CGFloat = 16
    static let cornerRadius: CGFloat = Radius.lg
    static let backgroundColor: Color = .backgroundSurface
    static let placeholderColor: Color = .textTertiary
}

// Developer finding a value:
// SearchBarTokens.backgroundColor → .backgroundSurface → asset catalog
// Two jumps maximum.
```

**Decision matrix for when to add a component token layer:**

| Condition | Use semantic tokens directly | Add component tokens |
|---|---|---|
| Component used in 1-2 places | Yes | No |
| Component used across 5+ screens | Maybe | Yes |
| Component has 3+ configurable dimensions | No | Yes |
| Component is in a shared framework/package | No | Yes |
| Token name is self-explanatory from context | Yes | No |

**Benefits:**
- Developers trace any value to its source in 1-2 jumps, not 5-6
- Fewer files to maintain, fewer abstraction layers to document
- Onboarding a new developer takes hours, not days
- Token naming debates happen once per layer, not five times

Reference: [Nathan Curtis — Naming Tokens in Design Systems](https://medium.com/eightshapes-llc/naming-tokens-in-design-systems-9e86c7444676)
