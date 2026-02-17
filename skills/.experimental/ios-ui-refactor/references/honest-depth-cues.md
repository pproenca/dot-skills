---
title: Use Materials for Layering, Not Drop Shadows for Depth
impact: HIGH
impactDescription: drop shadows as a primary depth cue produce 2-3 rendering artifacts in dark mode (invisible shadow, color bleed, contrast loss) — replacing with materials eliminates all three while reducing compositing layers by ~30%
tags: honest, depth, materials, shadows, rams-6, segall-brutal, platform
---

## Use Materials for Layering, Not Drop Shadows for Depth

You feel it before you can name it — a card with a drop shadow on iOS that looks almost right but not quite. Something about it is heavy, foreign, like a word borrowed from another language that never fully naturalizes. That instinct is correct: it speaks the wrong dialect. iOS communicates depth through blur and translucency; drop shadows belong to Material Design, where elevation is literal and measured in dp. Using `.shadow()` to separate UI layers on iOS is a visual lie — it says "this is how depth works here" while rendering an aesthetic that fights the lightness Apple's design language is built on. Shadows go invisible in dark mode, bleed color where they shouldn't, and clash with every system component sitting next to them. Reserve `.shadow()` for elements that genuinely float — draggable items mid-gesture, popovers, FABs — where the shadow tells a physical truth. For layered cards and grouped content, reach for materials: the honest depth cue that blurs the background and works in every appearance without rendering artifacts.

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

**Exceptional (the creative leap) — depth as spatial narrative:**

```swift
struct NowPlayingCard: View {
    @State private var isExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background layer — content shifts subtly behind the card,
            // creating a sense of depth you can almost reach into
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<20) { i in
                        PlaylistRow(index: i)
                    }
                }
                .padding()
            }
            .scaleEffect(isExpanded ? 0.92 : 1.0)
            .blur(radius: isExpanded ? 3 : 0)
            .animation(.smooth(duration: 0.4), value: isExpanded)

            // Foreground card — material separates the layer honestly,
            // shadow matches the system's own depth language
            VStack(spacing: 12) {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(.tertiary)

                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.quaternary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Midnight City")
                            .font(.headline)
                        Text("M83")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { } label: {
                        Image(systemName: "play.fill")
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(.thickMaterial,
                         in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 16, y: -4)
            .onTapGesture { isExpanded.toggle() }
        }
    }
}
```

The card does not just sit on top of the content — it creates a spatial moment. When it expands, the playlist behind it recedes gently: a slight scale-down and blur that tells your eye "this is further away now." The thick material lets the background breathe through, and the upward shadow with its soft 16-point blur matches the weight iOS uses for its own sheets. The result is layers you feel you could peel apart with your fingers. Depth becomes a gesture, not a decoration.

**When shadows are appropriate on iOS:**
- Floating action buttons (FABs) that physically hover over scrollable content
- Draggable items during an active drag gesture (lift-off feedback)
- Popovers and tooltips where the system itself adds shadows
- Navigation bar shadows on scroll (use `.toolbarBackground(.visible)` instead of manual shadows)

**When NOT to apply:** Card-to-background separation (use materials or `Color(.secondarySystemBackground)`), section grouping (use `GroupBox` or `Section` in a `List`), and any static layer boundary -- if it does not physically move, it should not cast a shadow.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC21 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/)
