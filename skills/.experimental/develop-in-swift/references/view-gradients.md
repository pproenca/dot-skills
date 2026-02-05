---
title: Apply Gradients for Visual Interest
impact: MEDIUM
impactDescription: modern app design, depth perception, smooth color transitions
tags: view, swiftui, gradients, design, backgrounds, styling
---

## Apply Gradients for Visual Interest

Use gradients for backgrounds and fills to add visual depth. SwiftUI provides `LinearGradient`, `RadialGradient`, and `AngularGradient`. Define colors in asset catalog for dark mode support.

**Incorrect (flat colors everywhere):**

```swift
// Flat backgrounds lack visual interest
VStack {
    // Content
}
.background(Color.blue)
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

**Gradient types:**
- `LinearGradient` - Colors transition along a line
- `RadialGradient` - Colors radiate from center
- `AngularGradient` - Colors sweep around center

Reference: [Develop in Swift Tutorials - Design an interface](https://developer.apple.com/tutorials/develop-in-swift/design-an-interface)
