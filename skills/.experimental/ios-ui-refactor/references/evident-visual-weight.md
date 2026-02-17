---
title: Combine Size, Weight, and Contrast for Hierarchy
impact: CRITICAL
impactDescription: relying on color alone to convey hierarchy fails for 8% of males with color vision deficiency — layering size + weight + contrast ensures hierarchy is perceivable by all users
tags: evident, typography, weight, contrast, rams-4, segall-human, accessibility
---

## Combine Size, Weight, and Contrast for Hierarchy

When every line of text looks the same, the eye drifts. Nothing pulls you in, nothing recedes — it's like listening to someone speak in a monotone. You can't tell what matters. But when size, weight, and contrast work together — the title steps forward, the timestamp falls back, the amount anchors the row — the hierarchy reads like a well-composed sentence, each word at the right volume. That effortless flow is what self-evident design feels like. Color alone can't carry it; 8% of males with color vision deficiency would lose the signal entirely. True visual hierarchy speaks through multiple channels layered together, so the structure is perceivable by every human eye.

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

**Exceptional (the creative leap) — hierarchy as emotional arc:**

```swift
struct NotificationView: View {
    let event: NotificationEvent

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // The moment: what happened
            Text(event.headline)
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            // The context: why it matters
            Text(event.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Spacer()

            // The action: what to do next — the only color
            Button(action: event.primaryAction) {
                Text(event.actionLabel)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)

            // The escape: low-priority dismiss
            Button("Not Now", action: event.dismiss)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
        }
        .padding(24)
    }
}
```

This isn't just a hierarchy — it's a narrative in three acts. The bold headline arrives first and lands with weight: something happened. The lighter, smaller detail line steps back and offers context without competing for attention. Then the eye falls to the only saturated element on the entire screen — the tinted action button — which resolves the tension the headline created. The "Not Now" option exists in `.tertiary`, barely visible, because it's an exit, not a destination. The emotional arc moves from impact to understanding to resolution, and visual weight is the instrument that conducts it. When hierarchy serves emotion rather than just logic, people don't read the screen — they *feel* it.

**When NOT to apply:**
- Decorative or artistic typography (e.g., a splash screen or promotional banner) where visual uniformity is an intentional stylistic choice
- Single-level lists where every item is genuinely equal in priority (e.g., a flat checklist) — forcing artificial hierarchy adds noise rather than clarity

**Benefits:**
- Passes WCAG 1.4.1 (Use of Color) — hierarchy never depends on color alone
- Survives grayscale, low brightness, and sunlight-washed screens
- Dynamic Type scales all three levels proportionally

Reference: [Color and Effects - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WCAG 1.4.1 Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color)
