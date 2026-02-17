---
title: One Primary Focal Point Per Screen
impact: CRITICAL
impactDescription: eliminates competing visual elements that cause users to tap back or scroll past without engaging — clear focal point reduces time-to-comprehension to under 2 seconds
tags: less, focal-point, rams-10, segall-minimal, cognitive-load
---

## One Primary Focal Point Per Screen

A screen with one clear focus feels like a quiet room — your eye settles on what matters without effort. A screen where three elements compete at equal visual weight feels like three people talking to you at once: you catch fragments of each but absorb none. The user arrives with a question — "whose profile is this?" or "what's the weather?" — and the screen has roughly two seconds to answer before attention fragments. When a bold title, a hero image, and a bright button all shout at equal volume, the user's first instinct is not engagement but retreat: they scroll past, tap back, or simply glaze over. Rams called this "concentration on essential aspects" — less design, not more. A principal designer establishes one dominant element, then deliberately quiets everything else through smaller type, lighter weight, and muted color. The result is a screen that breathes.

**Incorrect (three elements compete at equal visual weight):**

```swift
struct ProfileScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Three elements all fighting for attention
                Text("John Appleseed")
                    .font(.system(size: 34, weight: .bold))

                Image("profile-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()

                Text("Senior iOS Engineer at Apple")
                    .font(.system(size: 28, weight: .bold))

                Button("Send Message") {
                    // action
                }
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}
```

**Correct (clear primary, secondary, and tertiary hierarchy):**

```swift
struct ProfileScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // PRIMARY: hero image dominates the viewport
                Image("profile-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()

                VStack(spacing: 4) {
                    // SECONDARY: name is prominent but smaller than hero
                    Text("John Appleseed")
                        .font(.title)
                        .fontWeight(.semibold)

                    // TERTIARY: role is clearly subordinate
                    Text("Senior iOS Engineer at Apple")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button("Send Message") {
                    // action
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
    }
}
```

**Exceptional (the creative leap) — focal point that earns emotional response:**

```swift
struct ProfileScreen: View {
    @Namespace private var namespace

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // PRIMARY: hero image fills the viewport, pulls the user in
                Image("profile-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 360)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        // Name emerges from the image — part of the scene,
                        // not a separate element competing for attention
                        VStack(alignment: .leading, spacing: 2) {
                            Text("John Appleseed")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Senior iOS Engineer at Apple")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        .padding()
                    }

                // BREATHING ROOM: generous space before secondary content
                VStack(spacing: 16) {
                    Button("Send Message") { }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .padding(.top, 8)
            }
        }
    }
}
```

The exceptional version does not just fix hierarchy — it creates a *moment*. The name lives inside the hero image rather than competing with it, so the screen has one visual gesture rather than a stack of separate elements. The breathing room before the button lets the eye travel naturally from the portrait to the action. The user feels welcomed, not interrogated.

**Hierarchy audit checklist:**
- Squint at the screen — only one element should remain visible
- Primary element occupies the most visual area or has the heaviest weight
- Secondary elements use smaller type scale or reduced foreground style
- Tertiary elements use `.secondary` or `.tertiary` foreground styles
- Interactive elements (buttons) use system styles, not custom bold treatments

**When NOT to apply:** Comparison screens that deliberately present two or more options side by side (e.g., pricing tiers, product comparisons). Dashboards where 3-4 metric cards share equal importance. iPad split-view layouts where multiple panes serve distinct concurrent tasks.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
