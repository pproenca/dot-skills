---
title: Use MeshGradient for Premium Dynamic Backgrounds
impact: MEDIUM
impactDescription: produces organic, fluid backgrounds comparable to Apple Weather — replaces flat LinearGradient with GPU-accelerated multi-point color interpolation on hero surfaces
tags: modern, visual, gradient, ios18
---

## Use MeshGradient for Premium Dynamic Backgrounds

Flat solid colors and simple linear gradients read as utilitarian on hero surfaces — onboarding screens, subscription paywalls, and profile headers. `MeshGradient` interpolates colors across a grid of control points, producing organic, fluid backgrounds comparable to Apple Weather or Apple Music. This elevates perceived polish without requiring design assets.

**Incorrect (flat LinearGradient for a hero surface):**

```swift
struct PaywallHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
            Text("Upgrade to Pro")
                .font(.largeTitle.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
```

**Correct (MeshGradient with control points for organic color flow):**

```swift
struct PaywallHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
            Text("Upgrade to Pro")
                .font(.largeTitle.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .indigo, .blue, .purple,
                    .blue, .cyan, .indigo,
                    .purple, .indigo, .blue
                ]
            )
        )
    }
}
```

`MeshGradient` requires iOS 18+. Provide a `LinearGradient` fallback for iOS 17 deployments:

```swift
.background {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 3, height: 3, points: /* ... */, colors: /* ... */)
    } else {
        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
```

Limit `MeshGradient` to one per screen — multiple mesh gradients competing for attention dilute the premium effect. Animate control points with `TimelineView` for a living, breathing background on splash or paywall screens.

Reference: WWDC 2024 — "Create custom visual effects with SwiftUI"
