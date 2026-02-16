---
title: Extend ShapeStyle for Custom Colors, Not Color Directly
impact: CRITICAL
impactDescription: enables dot-syntax (.accentPrimary) that matches SwiftUI's native API (.primary, .secondary) for zero-friction adoption
tags: token, color, shapestyle, swiftui, api-design
---

## Extend ShapeStyle for Custom Colors, Not Color Directly

SwiftUI's `.foregroundStyle()`, `.tint()`, and `.background()` accept any `ShapeStyle`, not just `Color`. When you add static properties as `extension Color`, they work with `Color.accentPrimary` but NOT with the dot-syntax `.accentPrimary` inside `foregroundStyle()`. Extending `ShapeStyle where Self == Color` makes your custom colors behave identically to Apple's built-in `.primary`, `.secondary`, and `.tertiary` — the same dot-syntax, the same API ergonomics, zero learning curve.

**Incorrect (static properties on Color — broken dot-syntax):**

```swift
extension Color {
    static let textPrimary = Color("textPrimary")
    static let textSecondary = Color("textSecondary")
    static let backgroundSurface = Color("backgroundSurface")
    static let accentPrimary = Color("accentPrimary")
}

struct RecipeCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(Color.textPrimary)   // Verbose, doesn't match native API

            Text(subtitle)
                .foregroundStyle(Color.textSecondary)  // .textSecondary alone won't compile here
        }
        .padding()
        .background(Color.backgroundSurface)          // Must always prefix with Color
    }
}
```

**Correct (ShapeStyle extension — native dot-syntax):**

```swift
extension ShapeStyle where Self == Color {
    // MARK: - Text
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var textTertiary: Color { Color("textTertiary") }

    // MARK: - Backgrounds
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var backgroundElevated: Color { Color("backgroundElevated") }

    // MARK: - Interactive
    static var accentPrimary: Color { Color("accentPrimary") }
    static var accentSecondary: Color { Color("accentSecondary") }

    // MARK: - Status
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusWarning: Color { Color("statusWarning") }
    static var statusError: Color { Color("statusError") }

    // MARK: - Borders
    static var borderDefault: Color { Color("borderDefault") }
    static var borderSubtle: Color { Color("borderSubtle") }
}

@Equatable
struct RecipeCard: View {
    let title: String
    let subtitle: String
    let cookTime: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)        // Matches .primary syntax exactly

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)       // Clean dot-syntax

            Label(cookTime, systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.textTertiary)
        }
        .padding()
        .background(.backgroundSurface)               // Same ergonomics as .background
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.borderSubtle, lineWidth: 0.5)
        )
    }
}
```

**Why computed properties, not stored:**

```swift
// Use computed properties (var ... : Color { }) not stored (let ... =)
// Computed properties resolve at access time, respecting trait changes (dark mode toggles)

// Incorrect:
static let textPrimary = Color("textPrimary")  // Captured once, may not update

// Correct:
static var textPrimary: Color { Color("textPrimary") }  // Re-evaluated each access
```

**Benefits:**
- `.foregroundStyle(.textPrimary)` reads identically to `.foregroundStyle(.primary)` — zero cognitive overhead
- Works with every SwiftUI modifier that accepts ShapeStyle: `foregroundStyle`, `tint`, `background`, `overlay`, `stroke`
- Computed properties ensure correct behavior across appearance changes (light/dark mode transitions)
- Xcode autocomplete shows your custom colors alongside system colors

Reference: [ShapeStyle — Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/shapestyle), [WWDC21 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/)
