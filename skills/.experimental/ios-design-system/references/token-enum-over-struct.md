---
title: Use Caseless Enums for Token Namespaces
impact: CRITICAL
impactDescription: prevents accidental instantiation and provides natural namespacing without import overhead
tags: token, enum, namespace, organization, swift
---

## Use Caseless Enums for Token Namespaces

A struct with static properties can be instantiated — `let s = Spacing()` compiles and produces a meaningless value. A caseless enum (an enum with no cases) makes this a compile-time error. This is the standard Swift pattern used by Apple themselves (e.g., `DispatchTimeInterval`, `UIFont.TextStyle`). It provides zero-cost namespacing and communicates to readers that the type exists purely as a container for related constants.

**Incorrect (struct allows accidental instantiation):**

```swift
struct Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct Radius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999
}

// This compiles but is meaningless:
let spacing = Spacing()      // Empty struct instance — a bug waiting to happen
let radius = Radius()        // Same problem
```

**Correct (caseless enum prevents instantiation):**

```swift
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum Radius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999
}

enum Elevation {
    static let low: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.08), 2, 1)
    static let medium: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.12), 8, 4)
    static let high: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.16), 16, 8)
}

// Spacing()  // Compile error: cannot be constructed
// Radius()   // Compile error: same

// Usage in views:
Text("Hello")
    .padding(.horizontal, Spacing.md)
    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    .shadow(color: Elevation.low.color, radius: Elevation.low.radius, y: Elevation.low.y)
```

**Nested namespacing with caseless enums:**

```swift
enum DesignTokens {
    enum Animation {
        static let durationFast: Double = 0.15
        static let durationNormal: Double = 0.3
        static let durationSlow: Double = 0.5
        static let springResponse: Double = 0.55
        static let springDamping: Double = 0.825
    }

    enum Opacity {
        static let disabled: Double = 0.38
        static let dimmed: Double = 0.6
        static let overlay: Double = 0.72
    }
}

// Usage:
.animation(.spring(response: DesignTokens.Animation.springResponse,
                    dampingFraction: DesignTokens.Animation.springDamping), value: isExpanded)
.opacity(isEnabled ? 1 : DesignTokens.Opacity.disabled)
```

**Benefits:**
- Compile-time safety: impossible to create meaningless instances
- Self-documenting: `enum` signals "this is a namespace" to every reader
- Zero runtime cost: identical to struct statics in compiled output
- Consistent with Swift standard library patterns

Reference: [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/), [SE-0011 — Replace typealias keyword](https://github.com/apple/swift-evolution/blob/main/proposals/0011-replace-typealias-keyword.md)
