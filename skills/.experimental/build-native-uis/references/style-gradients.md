---
title: Apply Gradients for Visual Depth
impact: HIGH
impactDescription: gradients create visual hierarchy and polish with minimal code
tags: style, gradients, visual-design, backgrounds, theming
---

## Apply Gradients for Visual Depth

Flat solid color backgrounds can appear lifeless and make it harder for users to distinguish interactive elements from decorative surfaces. SwiftUI provides `LinearGradient`, `RadialGradient`, and `AngularGradient` that work directly with system colors and conform to `ShapeStyle`, enabling rich visual depth in a single modifier.

**Incorrect (flat solid color with no visual depth):**

```swift
struct PromotionBanner: View {
    let headline: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.blue) // flat, no visual depth
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (gradient background that adds visual hierarchy):**

```swift
struct PromotionBanner: View {
    let headline: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background( // gradient creates visual depth and directionality
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
