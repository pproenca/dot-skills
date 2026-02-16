---
title: Name Custom Colors by Role, Not Hue
impact: CRITICAL
impactDescription: reduces rebrand effort from 50-100 file changes to 1 asset catalog update — role-named colors survive palette changes with zero code modifications
tags: system, color, naming, edson-systems, rams-8, design-tokens
---

## Name Custom Colors by Role, Not Hue

Edson's systems thinking demands that colors participate in a coherent system, not as isolated hex values. "darkBlue" is a description, not a role. Rams' thoroughness requires that every naming decision be intentional — "textPrimary" describes function, survives a rebrand, and teaches new developers the system through reading the code.

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

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
