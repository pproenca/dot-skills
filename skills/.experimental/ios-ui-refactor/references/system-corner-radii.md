---
title: Standardize Corner Radii Per Component Type
impact: MEDIUM-HIGH
impactDescription: reduces corner radius variants from 8-12 arbitrary values to 3 named tiers — eliminates visual fragmentation across all component types
tags: system, corner-radius, edson-systems, rams-8, visual-coherence
---

## Standardize Corner Radii Per Component Type

Cards with different corner radii on the same screen produce a visual dissonance like furniture from different eras in the same room — a mid-century table next to a baroque chair next to a modernist lamp. Each piece is fine in isolation, but together they announce that nobody curated this space. When one card rounds at 8pt and its neighbor at 14pt, the eye registers the mismatch before the mind can explain it. Three radius tiers (small, medium, large), each assigned to a component type and enforced globally, are the curatorial decision that makes the whole screen feel like one collection.

**Incorrect (ad-hoc radii that vary by screen):**

```swift
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card 1: 8pt radius
                VStack {
                    Text("Steps Today")
                    Text("8,421")
                        .font(.title.bold())
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))

                // Card 2: 14pt radius — different from Card 1 for no reason
                VStack {
                    Text("Heart Rate")
                    Text("72 bpm")
                        .font(.title.bold())
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

                // Tag: 20pt radius — too large for a chip
                Text("Active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))

                // Button: 6pt radius — conflicts with everything above
                Button("View Details") { }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(.white)
            }
            .padding()
        }
    }
}
```

**Correct (three-tier radius scale applied by component type):**

```swift
enum CornerRadius {
    /// Chips, badges, tags, small inline elements
    static let small: CGFloat = 8
    /// Cards, inputs, buttons, list row backgrounds
    static let medium: CGFloat = 12
    /// Sheets, modals, full-width hero cards
    static let large: CGFloat = 16
}

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Both cards use the same medium radius
                VStack {
                    Text("Steps Today")
                    Text("8,421")
                        .font(.title.bold())
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))

                VStack {
                    Text("Heart Rate")
                    Text("72 bpm")
                        .font(.title.bold())
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))

                // Tag uses the small radius
                Text("Active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2), in: RoundedRectangle(cornerRadius: CornerRadius.small))

                // Button uses the medium radius — same tier as cards
                Button("View Details") { }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .foregroundStyle(.white)
            }
            .padding()
        }
    }
}
```

**Radius scale reference:**

```swift
// Tier       | Value | Use for
// -----------|-------|------------------------------------------
// small (8)  |  8pt  | Chips, badges, tags, toggles, small pills
// medium (12)| 12pt  | Cards, text fields, buttons, menu items
// large (16) | 16pt  | Bottom sheets, modals, hero cards, popovers

// Nested radius rule: when a rounded element contains another,
// the inner radius = outer radius - padding between them.
// Example: card with 12pt radius and 8pt padding → inner element uses 4pt radius.
```

**When NOT to apply:** Capsule shapes (`.capsule`) for pill buttons and search bars are intentionally distinct and do not need to match the radius scale. System controls like `Toggle` and `Picker` use their own radii.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
