---
title: Define Motion Tokens as a Caseless Enum for All Spring Presets
impact: CRITICAL
impactDescription: eliminates 100% of scattered spring literals — enables O(1) global motion updates instead of O(n) find-and-replace across every animated view
tags: spring, motion, tokens, design-system, dls
---

## Define Motion Tokens as a Caseless Enum for All Spring Presets

Scattered `.smooth`, `.snappy`, and `.bouncy` literals across a codebase create the same problem as hardcoded hex colors — they are impossible to audit, update, or keep consistent. When the design team decides that "standard" should feel slightly heavier, you must find and update every `.smooth` call in the app. A motion token enum solves this by centralizing all spring and timing values into named constants that describe intent, not implementation. This mirrors the token architecture pattern from `ios-design-system` (raw -> semantic -> component) applied to motion.

**Incorrect (scattered spring literals — no motion system):**

```swift
@Equatable
struct OrderCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Order #1042").font(.headline)
            if isExpanded {
                Text("2x Espresso").foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(.backgroundSurface, in: RoundedRectangle(cornerRadius: Radius.md))
        // .smooth here, .snappy there, .bouncy somewhere else —
        // no way to audit or globally adjust motion feel
        .animation(.smooth, value: isExpanded)
        .onTapGesture { isExpanded.toggle() }
    }
}
```

**Correct (motion tokens — one enum, every animation references it):**

```swift
// DesignSystem/Tokens/Motion.swift
enum Motion {
    // MARK: - Semantic Spring Tokens (the public API for animations)

    /// Standard UI transitions — expand/collapse, show/hide, layout changes.
    /// Zero bounce, natural deceleration. ~80% of all animations use this.
    static let standard: Animation = .smooth

    /// High-frequency interactive controls — toggles, tabs, checkboxes.
    /// Quick and decisive, no bounce.
    static let responsive: Animation = .snappy

    /// Celebratory or playful moments — success states, achievements, onboarding.
    /// Visible bounce, draws attention.
    static let playful: Animation = .bouncy

    // MARK: - Directional Tokens (enter vs exit asymmetry)

    /// View entrance — slightly longer to build spatial awareness (350ms feel).
    static let entrance: Animation = .smooth(duration: 0.35)

    /// View exit — fast to clear the screen (200ms feel).
    static let exit: Animation = .smooth(duration: 0.2)

    // MARK: - Weight Tokens (element mass)

    /// Heavy elements — bottom sheets, modals, large panels.
    /// Longer settle with subtle bounce.
    static let heavy: Animation = .spring(duration: 0.55, bounce: 0.18)

    /// Lightweight elements — tooltips, small popovers.
    /// Fast, no bounce.
    static let light: Animation = .spring(duration: 0.25, bounce: 0)
}
```

```swift
// Usage — clear intent, globally adjustable:
@Equatable
struct OrderCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Order #1042").font(.headline)
            if isExpanded {
                Text("2x Espresso").foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(.backgroundSurface, in: RoundedRectangle(cornerRadius: Radius.md))
        .animation(Motion.standard, value: isExpanded)
        .onTapGesture { isExpanded.toggle() }
    }
}
```

**Stagger timing tokens for orchestrated reveals:**

```swift
extension Motion {
    /// Stagger interval between child elements in a reveal sequence.
    static let staggerInterval: TimeInterval = 0.04

    /// Delay for the nth child in a staggered reveal.
    static func staggerDelay(index: Int) -> Animation {
        standard.delay(Double(index) * staggerInterval)
    }
}
```

**Motion token selection guide:**

| Intent | Token | Underlying Spring | Use for |
|--------|-------|-------------------|---------|
| General UI | `Motion.standard` | `.smooth` | Expand/collapse, show/hide, layout |
| Interactive controls | `Motion.responsive` | `.snappy` | Toggles, tabs, checkboxes, pickers |
| Celebration | `Motion.playful` | `.bouncy` | Success states, achievements |
| View appearing | `Motion.entrance` | `.smooth(duration: 0.35)` | Toasts, sheets, overlays entering |
| View disappearing | `Motion.exit` | `.smooth(duration: 0.2)` | Toasts, sheets, overlays leaving |
| Heavy container | `Motion.heavy` | `.spring(0.55, 0.18)` | Bottom sheets, modals, drawers |
| Light element | `Motion.light` | `.spring(0.25, 0)` | Tooltips, popovers, small popups |

**Benefits:**
- Rebrand motion feel = change token values in one file. Every animation updates globally.
- Code review catches violations easily: any bare `.smooth` or `.snappy` in a view is a red flag
- Consistent with ios-design-system's Spacing/Radius token pattern
- New developers search for `Motion.` and instantly discover all available animation presets

Reference: [Airbnb — Motion Engineering at Scale](https://medium.com/airbnb-engineering/motion-engineering-at-scale-5ffabfc878), [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
