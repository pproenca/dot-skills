---
title: "Use ZStack for Layered View Composition"
impact: CRITICAL
impactDescription: "enables overlay patterns for badges, watermarks, and loading states"
tags: layout, zstack, layering, overlays, composition
---

## Use ZStack for Layered View Composition

Attempting to layer views using chained `.overlay()` modifiers quickly becomes unreadable and hard to control when you need alignment, padding, or multiple overlapping elements. ZStack provides a dedicated container for layered composition where each child is a peer view, making the stacking order explicit and alignment straightforward.

**Incorrect (chained overlays become unreadable with multiple layers):**

```swift
struct FeaturedCardView: View {
    let imageName: String
    let cardTitle: String
    let cardSubtitle: String

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack(alignment: .leading) {
                    Spacer()
                    Text(cardTitle).font(.title2).bold()
                    Text(cardSubtitle).font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(), alignment: .bottomLeading // easy to misplace
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (ZStack makes layer order and alignment explicit):**

```swift
struct FeaturedCardView: View {
    let imageName: String
    let cardTitle: String
    let cardSubtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) { // single alignment for all layers
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(cardTitle).font(.title2).bold()
                Text(cardSubtitle).font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
