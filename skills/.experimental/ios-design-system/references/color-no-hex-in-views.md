---
title: Never Use Color Literals or Hex Initializers in View Code
impact: CRITICAL
impactDescription: prevents 100% of dark mode rendering bugs from hardcoded colors — every Color(hex:) is invisible to auditing and ungovernable during rebrands
tags: color, literals, hex, governance, consistency
---

## Never Use Color Literals or Hex Initializers in View Code

A `Color(hex: "#3B82F6")` embedded in a view is invisible to the design system. It cannot be found by searching for token names, it will not update during a rebrand, it has no dark mode variant, and it silently breaks visual consistency. The design system works only if every view resolves colors through the semantic token layer. Zero tolerance for raw color initialization in view files is the single most important governance rule for maintaining system integrity over time.

**Incorrect (raw color values in views):**

```swift
struct PaymentConfirmation: View {
    let amount: Decimal
    let isSuccessful: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(isSuccessful
                    ? Color(red: 0.2, green: 0.78, blue: 0.35)     // Ungoverned green
                    : Color(hex: "#FF3B30"))                         // Ungoverned red

            Text(isSuccessful ? "Payment Successful" : "Payment Failed")
                .font(.title2.bold())
                .foregroundStyle(Color(hex: "#1A1A2E"))              // Ungoverned text color

            Text(amount, format: .currency(code: "GBP"))
                .font(.largeTitle.bold())
                .foregroundStyle(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.18))  // Another ungoverned color

            Button("Done") { }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#5856D6"))                        // Ungoverned brand color
        }
        .padding(24)
        .background(Color(hex: "#FFFFFF"))                           // Ungoverned background
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
// 6 ungoverned colors in a single view. None will adapt to dark mode.
```

**Correct (all colors through semantic tokens):**

```swift
@Equatable
struct PaymentConfirmation: View {
    let amount: Decimal
    let isSuccessful: Bool

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(isSuccessful ? .statusSuccess : .statusError)

            Text(isSuccessful ? "Payment Successful" : "Payment Failed")
                .font(.title2.bold())
                .foregroundStyle(.textPrimary)

            Text(amount, format: .currency(code: "GBP"))
                .font(.largeTitle.bold())
                .foregroundStyle(.textPrimary)

            Button("Done") { }
                .buttonStyle(.borderedProminent)
            // .tint inherited from app root — no explicit color needed
        }
        .padding(Spacing.lg)
        .background(.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
    }
}
// 0 ungoverned colors. Every color adapts to dark mode automatically.
```

**Where raw color values ARE allowed:**

```swift
// 1. Inside the design system token definitions (and ONLY there)
// File: DesignSystem/Sources/Colors.swift
extension ShapeStyle where Self == Color {
    static var accentPrimary: Color { Color("accentPrimary") }  // Asset catalog reference
}

// 2. Dynamic colors derived from content (user avatar colors, image extraction)
AsyncImage(url: user.avatarURL) { image in
    image.resizable()
} placeholder: {
    Rectangle().fill(Color(hex: user.profileColorHex))  // User-generated, not a design token
}

// 3. One-off animation or visual effects
Circle()
    .fill(
        RadialGradient(
            colors: [.accentPrimary, .accentPrimary.opacity(0)],  // Derived from tokens
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    )
```

**Quick reference — what to search for in code review:**

| Pattern | Verdict |
|---|---|
| `.foregroundStyle(.textPrimary)` | Governed - correct |
| `.foregroundStyle(.primary)` | System color - correct |
| `.foregroundStyle(Color("textPrimary"))` | Verbose but governed - acceptable |
| `.foregroundStyle(Color(hex: "#333"))` | **UNGOVERNED - reject** |
| `.foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))` | **UNGOVERNED - reject** |
| `.foregroundStyle(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2))` | **UNGOVERNED - reject** |
| `.foregroundStyle(Color(uiColor: .label))` | System UIColor - acceptable |

**Benefits:**
- Every color in the app is auditable by searching for token names
- Dark mode works without any per-view logic
- Rebranding is a token-level change, not a codebase-wide find-and-replace
- Code review becomes binary: uses a token or it doesn't

Reference: [Color — Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color)
