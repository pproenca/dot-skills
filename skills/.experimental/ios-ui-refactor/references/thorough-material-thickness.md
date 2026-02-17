---
title: Choose Material Thickness by Contrast Needs
impact: HIGH
impactDescription: prevents 3-5 contrast failures per screen on variable backgrounds — correct thickness maintains 4.5:1 text contrast without per-context color overrides
tags: thorough, materials, thickness, rams-8, rams-2, contrast
---

## Choose Material Thickness by Contrast Needs

The card that is barely there — ultra-thin material over a pale background makes the card boundary almost invisible, and text floats in ambiguous space. The user cannot tell where the card ends and the background begins, so the grouping that the card was supposed to communicate dissolves. It looks like a rendering bug, not a design choice. Matching material thickness to background variance is the craft decision: vivid backgrounds can afford thin materials that let content show through, but subtle backgrounds need thicker materials to establish the boundary that gives the card its reason to exist.

**Incorrect (ultra-thin material over a low-contrast background — illegible text):**

```swift
struct ActivitySummary: View {
    var body: some View {
        ZStack {
            // Subtle, low-contrast gradient
            LinearGradient(colors: [Color(.systemGray5),
                                    Color(.systemGray6)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                SummaryCard(title: "Steps", value: "8,432")
                SummaryCard(title: "Calories", value: "524")
            }
            .padding()
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // Ultra-thin over low-contrast gray — card barely visible,
        // text has almost no contrast against background
        .background(.ultraThinMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (thick material for low-contrast backgrounds, thin for vivid ones):**

```swift
struct ActivitySummary: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemGray5),
                                    Color(.systemGray6)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                SummaryCard(title: "Steps", value: "8,432")
                SummaryCard(title: "Calories", value: "524")
            }
            .padding()
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // Thick material over subtle background — strong card
        // boundary with clear text readability
        .background(.thickMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Thickness selection by background type:**
| Background | Recommended Material | Reason |
|---|---|---|
| Vivid photo / video | `.ultraThinMaterial` | High contrast — let the content show through |
| Saturated gradient | `.thinMaterial` | Moderate blur preserves color while ensuring readability |
| Mixed / unknown content | `.regularMaterial` | Safe default — matches system navigation bars |
| Subtle gradient / near-solid | `.thickMaterial` | Needs stronger separation to define the card boundary |
| Text-heavy or uniform background | `.ultraThickMaterial` | Maximum readability, minimal background distraction |

**When NOT to apply:** Over rich photography or artwork where the visual content behind the overlay is the primary experience (e.g., album art, hero images). Thick materials obscure too much of the background, defeating the purpose of layered depth.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials)
