---
title: Name Custom Colors by Role, Not Hue
impact: CRITICAL
impactDescription: reduces rebrand effort from 50-100 file changes to 1 asset catalog update — role-named colors survive palette changes with zero code modifications
tags: system, color, naming, edson-systems, rams-8, design-tokens
---

## Name Custom Colors by Role, Not Hue

Naming a color "darkBlue" is a description — it tells you what the color looks like but nothing about what it does. Naming it "textPrimary" is a craft decision that teaches the system's language to every developer who reads the code. One name says "this is a shade"; the other says "this is the most important text on screen." When the brand palette changes next quarter, every "darkBlue" reference becomes a lie, while every "textPrimary" reference still means exactly what it says. Role-based naming turns the color system into a shared vocabulary that survives rebrands, onboards new teammates through code alone, and makes the relationship between every color intentional rather than incidental.

**Incorrect (colors named by hue in asset catalog and code):**

```swift
struct OrderCard: View {
    let orderTitle: String
    let orderStatus: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(orderTitle)
                .foregroundStyle(Color("darkBlue"))

            Text(orderStatus)
                .foregroundStyle(Color("lightGray"))
        }
        .padding()
        .background(Color("offWhite"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("brandRed"), lineWidth: 1)
        )
    }
}
```

**Correct (colors named by semantic role):**

```swift
extension ShapeStyle where Self == Color {
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var backgroundElevated: Color { Color("backgroundElevated") }
    static var accentAction: Color { Color("accentAction") }
    static var borderDefault: Color { Color("borderDefault") }
}

struct OrderCard: View {
    let orderTitle: String
    let orderStatus: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(orderTitle)
                .foregroundStyle(.textPrimary)

            Text(orderStatus)
                .foregroundStyle(.textSecondary)
        }
        .padding()
        .background(.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.borderDefault, lineWidth: 1)
        )
    }
}
```

**Role naming conventions:**
| Hue name (avoid) | Role name (use) | Purpose |
|---|---|---|
| `darkBlue` | `textPrimary` | Main readable text |
| `lightGray` | `textSecondary` | Supporting, de-emphasized text |
| `offWhite` | `backgroundElevated` | Card or sheet surface above base |
| `brandRed` | `accentAction` | Primary interactive element tint |
| `mediumGray` | `borderDefault` | Subtle dividers and card edges |
| `brightGreen` | `statusSuccess` | Positive outcome indicators |
| `alertOrange` | `statusWarning` | Caution state indicators |

**Benefits:**
- Asset catalog color sets still hold the actual hex values — renaming changes nothing in the catalog, only in code
- Dark mode variants are defined per role, not per hue, so "backgroundElevated" resolves to the right value in both appearances
- New team members read `foregroundStyle(.textSecondary)` and understand intent without checking a design spec

**When NOT to apply:** Illustration and artwork assets where the color IS the content (e.g., brand logo colors, photography tints), and rapid prototyping phases where semantic naming overhead slows iteration before the design language has stabilized.

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
