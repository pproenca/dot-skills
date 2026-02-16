---
title: Limit Custom Colors to Under 20 Semantic Tokens
impact: CRITICAL
impactDescription: reduces color token count by 50-70% (from 30+ to 15-20) — eliminates near-duplicate colors with 1-2px hex differences
tags: color, palette, consolidation, deduplication, design-system
---

## Limit Custom Colors to Under 20 Semantic Tokens

Design systems grow by accretion. A developer needs a "slightly lighter" background and adds `backgroundLightGray`. Another adds `backgroundOffWhite` which is 2 hex digits different. Within a year, the app has 40 custom colors, a third of which are near-duplicates that nobody can confidently remove. Constraining the palette to 15-20 semantic tokens forces consolidation up front. If a new color cannot fit an existing token, it is either a genuine new role (add it) or a visual deviation that should be realigned to the system (don't add it).

**Incorrect (bloated palette with near-duplicates):**

```swift
extension ShapeStyle where Self == Color {
    // Backgrounds — 8 tokens, several near-identical
    static var backgroundPrimary: Color { Color("backgroundPrimary") }         // #F2F2F7
    static var backgroundSecondary: Color { Color("backgroundSecondary") }     // #FFFFFF
    static var backgroundTertiary: Color { Color("backgroundTertiary") }       // #F5F5F5
    static var backgroundLight: Color { Color("backgroundLight") }             // #FAFAFA ← 3px from tertiary
    static var backgroundCard: Color { Color("backgroundCard") }               // #FFFFFF ← duplicate of secondary
    static var backgroundSheet: Color { Color("backgroundSheet") }             // #FFFFFF ← another duplicate
    static var backgroundInput: Color { Color("backgroundInput") }             // #F8F8F8 ← 3px from light
    static var backgroundHover: Color { Color("backgroundHover") }             // #F0F0F0

    // Text — 5 tokens, one never used
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var textTertiary: Color { Color("textTertiary") }
    static var textQuaternary: Color { Color("textQuaternary") }               // Used in 1 view
    static var textPlaceholder: Color { Color("textPlaceholder") }             // Same value as tertiary

    // ... 20 more tokens, total: 35+
}
```

**Correct (consolidated palette of ~16 tokens):**

```swift
extension ShapeStyle where Self == Color {
    // MARK: - Background (3 levels of elevation)
    static var backgroundPrimary: Color { Color("backgroundPrimary") }     // Base canvas
    static var backgroundSurface: Color { Color("backgroundSurface") }     // Cards, cells
    static var backgroundElevated: Color { Color("backgroundElevated") }   // Sheets, popovers

    // MARK: - Text (3 levels of emphasis)
    static var textPrimary: Color { Color("textPrimary") }                 // Headlines, body
    static var textSecondary: Color { Color("textSecondary") }             // Captions, metadata
    static var textTertiary: Color { Color("textTertiary") }               // Placeholders, disabled

    // MARK: - Border (2 levels)
    static var borderDefault: Color { Color("borderDefault") }             // Standard borders
    static var borderSubtle: Color { Color("borderSubtle") }               // Faint dividers

    // MARK: - Interactive (2 accents)
    static var accentPrimary: Color { Color("accentPrimary") }             // Primary actions, tint
    static var accentSecondary: Color { Color("accentSecondary") }         // Secondary actions

    // MARK: - Status (4 semantic states)
    static var statusSuccess: Color { Color("statusSuccess") }             // Positive
    static var statusWarning: Color { Color("statusWarning") }             // Caution
    static var statusError: Color { Color("statusError") }                 // Negative
    static var statusInfo: Color { Color("statusInfo") }                   // Informational

    // MARK: - Special (1-2 for specific needs)
    static var textInverse: Color { Color("textInverse") }                 // Text on dark fills
    static var overlayDimmed: Color { Color("overlayDimmed") }             // Scrim behind modals
}
// Total: 16 tokens. Covers 95% of use cases.
```

**What to do when a developer requests a new color:**

```text
Decision tree:
1. Does an existing token serve this purpose?
   → Yes: Use it. "backgroundSurface" works for cards, cells, and inputs.
   → No: Continue to step 2.

2. Is this a genuinely new semantic ROLE?
   (Not a visual variation, but a different purpose)
   → Yes: Add it. Example: "textLink" for tappable text is a new role.
   → No: Continue to step 3.

3. Can the design be adjusted to use an existing token?
   → Yes: Propose the alignment to the designer.
   → No: This is rare. Discuss with the team before adding.
```

**Recommended minimum set for a production app:**

| Role | Count | Examples |
|---|---|---|
| Backgrounds | 3 | primary, surface, elevated |
| Text | 3 | primary, secondary, tertiary |
| Borders | 1-2 | default, subtle |
| Accents | 1-2 | primary, secondary |
| Status | 3-4 | success, warning, error, info |
| Special | 1-2 | inverse, overlay |
| **Total** | **12-16** | |

**Benefits:**
- Near-duplicates are impossible when the budget is 16 tokens
- Developers spend zero time deciding between "backgroundLight" and "backgroundCard"
- Visual consistency is enforced by constraint, not by discipline
- Designers and developers share a small, memorizable vocabulary

Reference: [Material Design Color System](https://m3.material.io/styles/color/system/overview), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
