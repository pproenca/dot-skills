---
title: Combine Size, Weight, and Contrast for Hierarchy
impact: CRITICAL
impactDescription: relying on color alone to convey hierarchy fails for 8% of males with color vision deficiency — layering size + weight + contrast ensures hierarchy is perceivable by all users
tags: evident, typography, weight, contrast, rams-4, segall-human, accessibility
---

## Combine Size, Weight, and Contrast for Hierarchy

Rams demanded products be self-explanatory. When hierarchy relies on color alone, it fails the self-evidence test — 8% of males with color vision deficiency lose the signal entirely. Segall's Think Human means communicating through multiple channels that every human can perceive: size, weight, and contrast layered together.

**Incorrect (hierarchy relies on color alone):**

```swift
struct TransactionRow: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Same size, same weight — only color differentiates
                Text("Coffee Shop")
                    .font(.body)
                    .foregroundStyle(Color.black)

                Text("Today, 9:41 AM")
                    .font(.body)
                    .foregroundStyle(Color.gray) // only signal is color

                Text("Checking Account")
                    .font(.body)
                    .foregroundStyle(Color.blue) // color = category?
            }
            Spacer()
            Text("-$4.50")
                .font(.body)
                .foregroundStyle(Color.red) // red = negative, invisible to protanopia
        }
    }
}
```

**Correct (size + weight + foregroundStyle layered together):**

```swift
struct TransactionRow: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                // Level 1: largest + heaviest
                Text("Coffee Shop")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                // Level 2: smaller + lighter color
                Text("Today, 9:41 AM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Level 3: smallest + lightest
                Text("Checking Account")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            // Amount: weight + semantic color (not color alone)
            Text("-$4.50")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .accessibilityLabel("Debit four dollars and fifty cents")
        }
    }
}
```

**The three-axis hierarchy system:**

```swift
// Each level MUST differ on at least 2 of 3 axes
//
// Level      Size          Weight       ForegroundStyle
// ─────────────────────────────────────────────────────
// Primary    .body+        .semibold+   .primary
// Secondary  .subheadline  .regular     .secondary
// Tertiary   .caption      .regular     .tertiary

// Test: convert your UI to grayscale (Accessibility Inspector)
// If levels become indistinguishable, add a weight or size difference
```

**Benefits:**
- Passes WCAG 1.4.1 (Use of Color) — hierarchy never depends on color alone
- Survives grayscale, low brightness, and sunlight-washed screens
- Dynamic Type scales all three levels proportionally

Reference: [Color and Effects - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WCAG 1.4.1 Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color)
