---
title: Use Built-In symbolEffect, Not Manual Symbol Animation
impact: HIGH
impactDescription: eliminates 10-20 lines of manual keyframe code per symbol — system effects auto-adapt to Dynamic Type and Reduce Motion with zero extra code
tags: invisible, motion, sf-symbols, rams-5, edson-product, symbolEffect
---

## Use Built-In symbolEffect, Not Manual Symbol Animation

Rams' unobtrusive principle means the system handles complexity so the user doesn't see it. symbolEffect is Apple's built-in animation system for SF Symbols — it handles Reduce Motion, Dynamic Type, and platform timing invisibly. Manually animating symbols forces the mechanism into view. Edson's product-as-marketing: let the system's craft speak for itself.

**Incorrect (manual scale and opacity animation on SF Symbols):**

```swift
struct FavoriteButton: View {
    @State private var isFavorited = false
    @State private var symbolScale: CGFloat = 1.0

    var body: some View {
        Button {
            isFavorited.toggle()
            // Manual bounce: no accessibility fallback, timing is guesswork
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                symbolScale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    symbolScale = 1.0
                }
            }
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .scaleEffect(symbolScale)
                .foregroundStyle(isFavorited ? .red : .secondary)
        }
    }
}

struct DownloadIndicator: View {
    @State private var opacity = 0.3

    var body: some View {
        // Manual pulse loop: no Reduce Motion support
        Image(systemName: "arrow.down.circle")
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever()) {
                    opacity = 1.0
                }
            }
    }
}
```

**Correct (system symbolEffect for consistent, accessible animation):**

```swift
struct FavoriteButton: View {
    @State private var isFavorited = false
    @State private var bounceCount = 0

    var body: some View {
        Button {
            isFavorited.toggle()
            bounceCount += 1
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                // System bounce: respects Reduce Motion, consistent timing
                .symbolEffect(.bounce, value: bounceCount)
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(isFavorited ? .red : .secondary)
        }
    }
}

struct DownloadIndicator: View {
    var body: some View {
        // System pulse: automatically pauses for Reduce Motion
        Image(systemName: "arrow.down.circle")
            .symbolEffect(.pulse)
    }
}
```

**Available symbol effects:**

| Effect | Use for |
|--------|---------|
| `.bounce` | Tap feedback, value changes |
| `.pulse` | Ongoing activity, waiting states |
| `.variableColor` | Progress indication (Wi-Fi, signal strength) |
| `.replace` | Transitioning between two different symbols |
| `.breathe` | Ambient, passive attention (iOS 18+) |

**Reference:** WWDC 2023 "Animate symbols in your app"; Apple HIG "SF Symbols" — symbol effects are the canonical way to animate SF Symbols and are designed to work across all Apple platforms.
