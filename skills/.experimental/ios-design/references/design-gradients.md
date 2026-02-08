---
title: Apply Gradients for Visual Depth
impact: HIGH
impactDescription: gradients create visual hierarchy and polish with minimal code
tags: design, gradients, visual-design, backgrounds, theming, styling
---

## Apply Gradients for Visual Depth

Flat solid color backgrounds can appear lifeless and make it harder for users to distinguish interactive elements from decorative surfaces. SwiftUI provides `LinearGradient`, `RadialGradient`, and `AngularGradient` that work directly with system colors and conform to `ShapeStyle`, enabling rich visual depth in a single modifier.

**Incorrect (flat solid color with no visual depth):**

```swift
VStack {
    Text("Welcome")
        .font(.largeTitle)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
.background(Color.blue) // flat, no visual depth
```

**Correct (gradient backgrounds):**

```swift
// Linear gradient
VStack {
    Text("Welcome")
        .font(.largeTitle)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
.background(
    LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)

// Using asset catalog colors for dark mode support
.background(
    LinearGradient(
        colors: [Color("GradientStart"), Color("GradientEnd")],
        startPoint: .top,
        endPoint: .bottom
    )
)

// Gradient on shapes
RoundedRectangle(cornerRadius: 12)
    .fill(
        LinearGradient(
            colors: [.orange, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .frame(height: 100)

// Radial gradient for spotlight effects
Circle()
    .fill(
        RadialGradient(
            colors: [.white, .clear],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    )
```

**Gradient on a promotion banner:**

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
        .background(
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

**Gradient types:**
- `LinearGradient` - Colors transition along a line
- `RadialGradient` - Colors radiate from center
- `AngularGradient` - Colors sweep around center

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
