---
title: Prefer System Colors Before Defining Custom Tokens
impact: CRITICAL
impactDescription: eliminates 30-50% of custom color tokens — system colors (.primary, .secondary, .background) auto-adapt to 4 appearance modes for free
tags: color, system-colors, platform, maintenance, pragmatism
---

## Prefer System Colors Before Defining Custom Tokens

SwiftUI ships with a complete set of semantic system colors that auto-adapt to light mode, dark mode, high contrast, and elevated contrast — for free. Every custom color token you add is a value you must maintain across all four appearance combinations, test manually, and keep synchronized with design updates. Before adding any custom token, verify that a system color does not already serve the same purpose. The design system should extend Apple's system, not replace it.

**Incorrect (custom tokens that map to identical system color values):**

```swift
extension ShapeStyle where Self == Color {
    // These map to the EXACT same appearance as system colors — unnecessary maintenance debt
    static var textPrimary: Color { Color("textPrimary") }       // Visually identical to .primary
    static var textSecondary: Color { Color("textSecondary") }   // Visually identical to .secondary
    static var textDisabled: Color { Color("textDisabled") }     // Visually identical to .tertiary
    static var backgroundBase: Color { Color("backgroundBase") } // Visually identical to Color(.systemBackground)
    static var separator: Color { Color("separator") }           // Visually identical to .separator (built-in)
    // If your brand text colors use specific hex values that DIFFER from system colors,
    // then custom tokens like .textPrimary ARE correct — see token-shapestyle-extensions
}

struct SettingsRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.textPrimary)      // Custom token = system .primary
            Spacer()
            Text(detail)
                .foregroundStyle(.textSecondary)     // Custom token = system .secondary
        }
        .padding()
        .background(.backgroundBase)                // Custom token = system background
    }
}
```

**Correct (system colors first, custom tokens only for gaps):**

```swift
// Use system colors for standard roles — no custom tokens needed
@Equatable
struct SettingsRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)          // Built-in, auto-adapts
            Spacer()
            Text(detail)
                .foregroundStyle(.secondary)         // Built-in, auto-adapts
        }
        .padding()
        // No explicit background needed — inherits system background
    }
}

// Define custom tokens ONLY for colors that diverge from system defaults
extension ShapeStyle where Self == Color {
    // Brand-specific: no system equivalent
    static var accentPrimary: Color { Color("accentPrimary") }
    static var accentSecondary: Color { Color("accentSecondary") }

    // Status colors: system colors are too generic
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusWarning: Color { Color("statusWarning") }
    static var statusError: Color { Color("statusError") }

    // Brand backgrounds: intentionally different from system
    static var backgroundBrand: Color { Color("backgroundBrand") }

    // Elevated surface with specific brand treatment
    static var backgroundElevated: Color { Color("backgroundElevated") }
}
```

**System colors available in SwiftUI and when to use them:**

| System Color | Purpose | Custom token needed? |
|---|---|---|
| `.primary` | Main text, high emphasis | No — use directly |
| `.secondary` | Supporting text, medium emphasis | No — use directly |
| `.tertiary` | Disabled text, low emphasis | No — use directly |
| `.quaternary` | Barely visible text/fills | No — use directly |
| `Color(.systemBackground)` | Root view background | Usually no |
| `Color(.secondarySystemBackground)` | Grouped table background | Usually no |
| `Color(.tertiarySystemBackground)` | Inner grouped content | Usually no |
| `Color(.separator)` | Standard list separator | No — use directly |
| `Color(.systemGroupedBackground)` | Grouped list background | No — use directly |
| `.tint` | Interactive element color | Set once at app root |
| `.red`, `.green`, `.blue`, `.orange` | Status indicators | Only if brand-specific |

**Decision matrix — do I need a custom token?**

```text
1. Does a SwiftUI system color serve this purpose?
   → .primary, .secondary, .tertiary for text
   → Color(.systemBackground) variants for surfaces
   → .red/.green/.orange for status
   If yes: USE THE SYSTEM COLOR. Done.

2. Does the design intentionally diverge from the system default?
   → Brand-specific accent color: YES, add token
   → Brand-specific background: YES, add token
   → Status color that must match brand guidelines: YES, add token
   → Text color that looks exactly like .primary: NO, use .primary

3. Will this color need dark/light variants different from system?
   → If the system variant already matches both modes: use system
   → If brand requires specific hex values: add custom token
```

**Benefits:**
- Fewer custom tokens to maintain: 6-8 custom tokens + system colors vs. 25+ all-custom
- Automatic adaptation to accessibility settings (high contrast, bold text, increased contrast)
- Platform consistency: your app feels native because it uses native colors
- Future-proof: when Apple updates system colors for new hardware, your app benefits automatically

Reference: [Color — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [UIColor System Colors — Apple Developer](https://developer.apple.com/documentation/uikit/uicolor/standard_colors)
