---
title: One Primary Focal Point Per Screen
impact: CRITICAL
impactDescription: screens with 2+ competing focal points increase time-to-comprehension by 40-60% — users tap back or scroll past without engaging
tags: hier, focal-point, attention, cognitive-load, layout
---

## One Primary Focal Point Per Screen

Every screen must answer one question instantly: "What should I look at first?" When multiple elements compete for dominance through equal size, weight, or saturation, the eye has nowhere to land. A principal designer establishes a single primary element, then subordinates everything else through deliberate size, weight, and contrast reduction.

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

Reference: [WWDC21 — Design for Safari 15](https://developer.apple.com/videos/play/wwdc2021/10029/) (focal point principles), [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
