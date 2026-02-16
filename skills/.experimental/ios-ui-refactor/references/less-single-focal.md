---
title: One Primary Focal Point Per Screen
impact: CRITICAL
impactDescription: eliminates competing visual elements that cause users to tap back or scroll past without engaging — clear focal point reduces time-to-comprehension to under 2 seconds
tags: less, focal-point, rams-10, segall-minimal, cognitive-load
---

## One Primary Focal Point Per Screen

Dieter Rams' tenth principle demands "concentration on essential aspects." Ken Segall's "Think Minimal" showed that Apple's resurgence came from distilling product lines to the absolute minimum — not 350 products, but 10. The same discipline applies to every screen you design. Multiple competing elements is the opposite of "less, but better." When three elements fight for dominance through equal size, weight, or saturation, you force the user to make a parsing decision before they can even begin the task they came to accomplish. Every screen must answer one question instantly: "What should I look at first?" A principal designer establishes a single primary element, then subordinates everything else through deliberate size, weight, and contrast reduction.

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

**Hierarchy audit checklist:**
- Squint at the screen — only one element should remain visible
- Primary element occupies the most visual area or has the heaviest weight
- Secondary elements use smaller type scale or reduced foreground style
- Tertiary elements use `.secondary` or `.tertiary` foreground styles
- Interactive elements (buttons) use system styles, not custom bold treatments

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
