---
title: Use Repeating Spring for Organic Loading States
impact: MEDIUM
impactDescription: spring-based loading pulses feel alive; linear pulsing feels mechanical
tags: micro, loading, pulse, shimmer, repeating
---

## Use Repeating Spring for Organic Loading States

Loading indicators and skeleton screens should pulse with spring physics, not linear timing. A `.repeatForever` with `.easeInOut` on opacity produces a metronomic pulse — perfectly even, perfectly robotic. Real objects do not pulse with mathematical regularity. `PhaseAnimator` with two phases creates an organic breathing effect where the timing of each phase can vary, and springs add natural ease at the reversals. For shimmer effects, a gradient offset animation creates the illusion of light passing over the placeholder.

**Incorrect (easeInOut repeat creates metronomic, robotic pulsing):**

```swift
struct SkeletonRow: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 160, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 12)
            }
        }
        .padding()
        // Metronomic: every pulse is exactly the same duration with the
        // same easing. Feels like a blinking cursor, not a living placeholder.
        .opacity(isAnimating ? 0.4 : 1.0)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}
```

**Correct (PhaseAnimator creates organic, breathing pulse):**

```swift
enum PulsePhase: CaseIterable {
    case dim
    case bright

    var opacity: Double {
        switch self {
        case .dim: return 0.4
        case .bright: return 1.0
        }
    }

    var animation: Animation {
        switch self {
        case .dim: return .smooth(duration: 0.8)
        case .bright: return .smooth(duration: 1.0)
        }
    }
}

struct SkeletonRow: View {
    var body: some View {
        PhaseAnimator(PulsePhase.allCases) { phase in
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 160, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 12)
                }
            }
            .padding()
            // Asymmetric durations: dim slowly, brighten faster — feels
            // like breathing, not blinking
            .opacity(phase.opacity)
        } animation: { phase in
            phase.animation
        }
    }
}
```

**Shimmer effect using gradient offset animation:**

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 200)
                .mask(content)
            }
            .onAppear {
                withAnimation(
                    .smooth(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// Usage:
struct LoadingCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 180)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 200, height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 140, height: 12)
        }
        .padding()
        .shimmer()
    }
}
```

**Spinner with spring-based rotation:**

```swift
struct OrganicSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                Color.accentColor,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .linear(duration: 0.8)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}
```

**Loading style comparison:**

| Technique | Best for | Feel |
|---|---|---|
| `PhaseAnimator` pulse | Skeleton screens, placeholder content | Organic breathing |
| Shimmer gradient | Cards, list rows, image placeholders | Light sweeping across surface |
| `.smooth` repeat | Subtle glow, opacity pulse | Calm, unobtrusive |
| `ProgressView()` | System-standard spinner | Native, expected |

**Key insight:** `PhaseAnimator` is the iOS 17 replacement for the old "toggle a bool on appear" pattern. It manages its own state, cycles through phases automatically, and lets you specify different animations per phase transition. This is what enables asymmetric timing — dim slowly, brighten quickly — which is what makes the pulse feel like breathing instead of blinking.

Reference: [WWDC 2023 — Explore SwiftUI animation](https://developer.apple.com/wwdc23/10156)
