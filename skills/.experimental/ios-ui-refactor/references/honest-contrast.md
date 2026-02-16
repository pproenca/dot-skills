---
title: Ensure WCAG AA Contrast Ratios
impact: CRITICAL
impactDescription: text below 4.5:1 contrast ratio is unreadable for 8% of male users with color vision deficiency and most users over 50 — failing AA compliance exposes legal liability under ADA and EAA
tags: honest, contrast, accessibility, rams-6, segall-brutal, wcag
---

## Ensure WCAG AA Contrast Ratios

Rams insisted that design must not manipulate the consumer with promises that cannot be kept. Low-contrast text promises readability but delivers illegibility — `Color.gray.opacity(0.5)` on white looks refined on a designer's monitor but produces a contrast ratio of 1.8:1, less than half the WCAG AA minimum. It says "you can read this" while offering text that is invisible to 8% of male users with color vision deficiency and most users over 50. Segall's Think Brutal: if 8% of users cannot read your text, your interface is lying about its accessibility. An honest interface uses Apple's pre-validated semantic styles (`.primary`, `.secondary`, `.tertiary`) that meet AA ratios in both appearances, or it tests custom colors with the Accessibility Inspector and ships contrast pairs that actually work.

**Incorrect (decorative opacity destroys legibility):**

```swift
struct PaymentSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)

            HStack {
                Text("Subtotal")
                    .foregroundStyle(Color.gray.opacity(0.5))
                Spacer()
                Text("$42.00")
                    .foregroundStyle(Color.gray.opacity(0.5))
            }

            HStack {
                Text("Tax")
                    .foregroundStyle(Color.gray.opacity(0.4))
                Spacer()
                Text("$3.36")
                    .foregroundStyle(Color.gray.opacity(0.4))
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("$45.36")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
        }
        .padding()
        .background(.white)
    }
}
```

**Correct (system-validated semantic styles meet AA minimums):**

```swift
struct PaymentSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)

            HStack {
                Text("Subtotal")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$42.00")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Tax")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$3.36")
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("$45.36")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
```

**Minimum contrast ratios (WCAG 2.1 AA):**
| Text type | Minimum ratio | Example |
|---|---|---|
| Body text (< 18pt) | 4.5:1 | `.secondary` on system background passes |
| Large text (>= 18pt bold or >= 24pt) | 3:1 | `.tertiary` on system background passes |
| UI components and icons | 3:1 | Inactive controls, chevrons, dividers |
| Decorative only | No minimum | Background textures, non-informational art |

**Verification workflow:**
1. Open Xcode Accessibility Inspector (Xcode → Open Developer Tool → Accessibility Inspector)
2. Use the Color Contrast Calculator to check foreground/background pairs
3. Toggle between light and dark mode — a color that passes in light may fail in dark
4. Enable Increase Contrast in Settings → Accessibility → Display & Text Size and verify again

**When NOT to enforce AA:** Placeholder text in search bars that disappears on focus, purely decorative gradient overlays, and disabled controls (which have separate WCAG guidance at 3:1).

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility), [WCAG 2.1 Success Criterion 1.4.3](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
