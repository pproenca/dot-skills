---
title: Use Materials for Layering, Not Drop Shadows for Depth
impact: HIGH
impactDescription: drop shadows as a primary depth cue produce a Material Design aesthetic that clashes with iOS's blur-based layering system — replacing shadow-based elevation with materials aligns with the native visual language and eliminates dark-mode shadow rendering issues
tags: depth, materials, shadows, elevation, layering, platform
---

## Use Materials for Layering, Not Drop Shadows for Depth

iOS communicates depth through blur and translucency, not through shadow-based elevation. When a card hovers over content, iOS blurs the background behind it (materials); Android/Material Design casts a shadow beneath it (elevation). Reaching for `.shadow()` to separate UI layers is the single most common cross-platform design leak. The result looks subtly wrong on iOS — shadows that are invisible in dark mode, inconsistent with system components that use no shadows, and a visual weight that fights the lightness of Apple's design language. Reserve `.shadow()` for physically floating elements: FABs, draggable items, and popovers where the element genuinely lifts off the surface.

**Incorrect (shadow-based elevation for layered cards):**

```swift
struct FeedCard: View {
    let title: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        // Shadow as depth cue — Material Design pattern
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

struct FeedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FeedCard(title: "Getting Started",
                         summary: "Learn the basics of the platform.")
                FeedCard(title: "Advanced Tips",
                         summary: "Power-user techniques and shortcuts.")
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
    }
}
```

**Correct (material-based layering for cards, shadow only for floating actions):**

```swift
struct FeedCard: View {
    let title: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // Material — iOS depth through blur, not shadow
        .background(.regularMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FeedView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    FeedCard(title: "Getting Started",
                             summary: "Learn the basics of the platform.")
                    FeedCard(title: "Advanced Tips",
                             summary: "Power-user techniques and shortcuts.")
                }
                .padding()
            }

            // FAB — physically floating, shadow is correct here
            Button {
                // compose action
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue, in: Circle())
                    .shadow(color: .black.opacity(0.25),
                            radius: 8, y: 4)
            }
            .padding()
        }
    }
}
```

**When shadows are appropriate on iOS:**
- Floating action buttons (FABs) that physically hover over scrollable content
- Draggable items during an active drag gesture (lift-off feedback)
- Popovers and tooltips where the system itself adds shadows
- Navigation bar shadows on scroll (use `.toolbarBackground(.visible)` instead of manual shadows)

**When NOT to use shadows:**
- Card-to-background separation (use materials or `Color(.secondarySystemBackground)`)
- Section grouping (use `GroupBox` or `Section` in a `List`)
- Any static layer boundary — if it does not physically move, it should not cast a shadow

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC21 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/)
