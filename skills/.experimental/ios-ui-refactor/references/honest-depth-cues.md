---
title: Use Materials for Layering, Not Drop Shadows for Depth
impact: HIGH
impactDescription: drop shadows as a primary depth cue produce 2-3 rendering artifacts in dark mode (invisible shadow, color bleed, contrast loss) — replacing with materials eliminates all three while reducing compositing layers by ~30%
tags: honest, depth, materials, shadows, rams-6, segall-brutal, platform
---

## Use Materials for Layering, Not Drop Shadows for Depth

Rams demanded that design be honest about the medium. iOS communicates depth through blur and translucency; drop shadows are the honest language of a different platform (Material Design). Using `.shadow()` to separate UI layers on iOS is a visual lie — it speaks the wrong dialect. It says "this is how depth works here" while rendering an aesthetic that feels subtly wrong: shadows invisible in dark mode, inconsistent with system components that use no shadows, and a visual weight that fights the lightness of Apple's design language. Segall's Think Brutal: stop pretending your iOS app is an Android app. Reserve `.shadow()` for physically floating elements — FABs, draggable items, popovers — where the element genuinely lifts off the surface. For layered cards and grouped content, use materials: the honest depth cue that blurs the background and works in every appearance without rendering artifacts.

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
