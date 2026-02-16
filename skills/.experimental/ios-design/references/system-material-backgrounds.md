---
title: Use Material Backgrounds for Depth and Layering
impact: HIGH
impactDescription: system materials eliminate 5-15 lines of manual opacity/blur tuning per overlay — automatically handles 4 appearance modes (light, dark, high contrast, reduced transparency) vs 4× the conditional code for hand-tuned values
tags: system, material, background, depth, kocienda-convergence, edson-systems
---

## Use Material Backgrounds for Depth and Layering

Edson's systems thinking recognizes that depth is a system-level concern, not an individual view decision. Apple's material system — `.ultraThinMaterial` through `.ultraThickMaterial` — provides consistent blur, saturation, and tint that automatically adapt to the background content, appearance mode, and accessibility settings. Kocienda's convergence applies: the design team tested dozens of blur amounts before converging on a system of predefined materials that work everywhere. When you hand-tune `Color.white.opacity(0.7)`, you opt out of that system and guarantee your overlay looks wrong on at least one background.

**Incorrect (hand-tuned opacity that breaks on varied backgrounds):**

```swift
struct FloatingCard: View {
    var body: some View {
        VStack {
            Text("Now Playing")
                .font(.headline)
            Text("Midnight Rain — Taylor Swift")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        // Looks fine on white, terrible on dark photos or gradients
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (system material that adapts to any background):**

```swift
struct FloatingCard: View {
    var body: some View {
        VStack {
            Text("Now Playing")
                .font(.headline)
            Text("Midnight Rain — Taylor Swift")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Material thickness guide:**
| Material | Blur Amount | Use Case |
|----------|-------------|----------|
| `.ultraThinMaterial` | Lightest | Full-screen overlays where content must remain legible |
| `.thinMaterial` | Light | Navigation bars over scrolling content |
| `.regularMaterial` | Medium | Cards, floating panels, bottom sheets |
| `.thickMaterial` | Heavy | Modals, prominent overlays |
| `.ultraThickMaterial` | Heaviest | Critical alerts needing maximum readability |
| `.bar` | System bar | Tab bars, toolbars (matches system exactly) |

**When NOT to use materials:** Solid backgrounds for primary content areas (use `Color(.systemBackground)` instead). Materials are for layered, floating, or overlapping content where the background showing through provides spatial context.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials)
