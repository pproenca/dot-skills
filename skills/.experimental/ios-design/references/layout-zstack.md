---
title: Use ZStack for Purposeful Layered Composition
impact: HIGH
impactDescription: ZStack reduces 3+ nested .overlay/.background chains to a single flat structure — saves 5-10 lines per layered component and cuts body complexity by 40-60% for multi-layer compositions
tags: layout, zstack, layering, overlay, edson-design-out-loud, kocienda-intersection
---

## Use ZStack for Purposeful Layered Composition

Edson's "Design Out Loud" means making layering decisions explicit. `ZStack` arranges views front-to-back, with each subsequent view layered on top of the previous one. This is the right tool for overlays (gradient scrims over images), badges (notification counts on icons), floating elements (bottom sheets over content), and background decorations. Kocienda's intersection principle demands that each layer serves a purpose — decorative, informational, or interactive.

**Incorrect (overlay modifier for complex multi-layer composition):**

```swift
struct HeroCard: View {
    let event: Event

    var body: some View {
        Image(event.imageName)
            .resizable()
            .scaledToFill()
            .frame(height: 250)
            .clipped()
            // Nested overlays become hard to read
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [.clear, .black.opacity(0.7)],
                               startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading) {
                    Text(event.title).font(.title2.bold())
                    Text(event.date.formatted()).font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding()
            }
    }
}
```

**Correct (ZStack with clear layer ordering):**

```swift
struct HeroCard: View {
    let event: Event

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 1: Background image
            Image(event.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 250)
                .clipped()

            // Layer 2: Gradient scrim for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Layer 3: Foreground text
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.title2.bold())
                Text(event.date.formatted())
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**ZStack vs overlay vs background:**
| Scenario | Use | Why |
|----------|-----|-----|
| Multi-layer composition | `ZStack` | Clear layer ordering, shared alignment |
| Single decoration on content | `.overlay` / `.background` | Simpler for one layer |
| Badge on icon | `.overlay(alignment:)` | Badge is clearly secondary |
| Floating button over scroll | `ZStack` | Independent positioning needed |

**When NOT to use ZStack:** For simple "icon next to text" layouts, use `HStack`. For "title above content," use `VStack`. ZStack is specifically for overlapping content, not general layout.

Reference: [Layout fundamentals - Apple Documentation](https://developer.apple.com/documentation/swiftui/layout-fundamentals)
