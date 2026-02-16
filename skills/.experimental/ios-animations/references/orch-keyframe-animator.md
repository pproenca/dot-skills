---
title: Use KeyframeAnimator for Timeline-Precise Motion
impact: HIGH
impactDescription: keyframes provide millisecond-precise cross-property timing that PhaseAnimator cannot — Airbnb's Host Passport uses 200ms scale peaks with offset-150ms rotation starts for branded reveal sequences
tags: orch, keyframeAnimator, timeline, precise, choreography
---

## Use KeyframeAnimator for Timeline-Precise Motion

When you need millisecond-precise control over animation timing — a branded loading animation where scale peaks at exactly 200ms while rotation starts at 150ms, or a logo reveal where opacity and position follow different timing curves — `PhaseAnimator` falls short because it sequences phases linearly and does not let properties follow independent timelines. `KeyframeAnimator` (iOS 17+) solves this by giving each animatable property its own timeline track with explicit timestamps and interpolation curves.

Think of `KeyframeAnimator` like a video editing timeline: each property (scale, rotation, offset) has its own track, and you place keyframes at specific times on each track independently. Between keyframes, SwiftUI interpolates using the curve you specify — `.linear`, `.spring`, or `.cubic` (for bezier control).

**Incorrect (PhaseAnimator with forced delays — no precise cross-property timing):**

```swift
struct LogoReveal: View {
    enum Phase: CaseIterable {
        case hidden, appearing, bounced, settled

        var scale: CGFloat {
            switch self {
            case .hidden: return 0.3
            case .appearing: return 1.15
            case .bounced: return 0.95
            case .settled: return 1.0
            }
        }

        var opacity: Double {
            switch self {
            case .hidden: return 0
            case .appearing, .bounced, .settled: return 1
            }
        }

        var yOffset: CGFloat {
            switch self {
            case .hidden: return 30
            case .appearing: return -5
            case .bounced: return 2
            case .settled: return 0
            }
        }
    }

    @State private var trigger = false

    var body: some View {
        // PhaseAnimator steps through phases linearly.
        // You cannot make scale peak at 200ms while offset settles at 350ms —
        // every property transitions together per phase.
        PhaseAnimator(Phase.allCases, trigger: trigger) { phase in
            Image(systemName: "apple.logo")
                .font(.system(size: 80))
                .scaleEffect(phase.scale)
                .opacity(phase.opacity)
                .offset(y: phase.yOffset)
        } animation: { _ in
            .spring(duration: 0.25, bounce: 0.2)
        }
        .onAppear { trigger.toggle() }
    }
}
```

**Correct (KeyframeAnimator — each property follows its own timeline):**

```swift
struct AnimationValues {
    var scale: CGFloat = 0.3
    var opacity: Double = 0
    var yOffset: CGFloat = 30
    var rotation: Double = -10
}

@Equatable
struct LogoReveal: View {
    @State private var trigger = false

    var body: some View {
        KeyframeAnimator(
            initialValue: AnimationValues(),
            trigger: trigger
        ) { values in
            Image(systemName: "apple.logo")
                .font(.system(size: 80))
                .scaleEffect(values.scale)
                .opacity(values.opacity)
                .offset(y: values.yOffset)
                .rotationEffect(.degrees(values.rotation))
        } keyframes: { _ in
            // Scale: fast overshoot, then settle
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.15, duration: 0.25, spring: .snappy)
                SpringKeyframe(0.95, duration: 0.15, spring: .smooth)
                SpringKeyframe(1.0, duration: 0.2, spring: .smooth)
            }

            // Opacity: quick fade in (independent of scale timing)
            KeyframeTrack(\.opacity) {
                LinearKeyframe(1.0, duration: 0.15)
            }

            // Vertical offset: slides up, overshoots, settles
            KeyframeTrack(\.yOffset) {
                SpringKeyframe(-8, duration: 0.2, spring: .snappy)
                SpringKeyframe(3, duration: 0.15, spring: .smooth)
                SpringKeyframe(0, duration: 0.25, spring: .smooth)
            }

            // Rotation: straightens out independently
            KeyframeTrack(\.rotation) {
                CubicKeyframe(2, duration: 0.2)
                CubicKeyframe(0, duration: 0.2)
            }
        }
        .onAppear { trigger.toggle() }
    }
}
```

**Keyframe types and when to use each:**

```swift
// Available keyframe types:
KeyframeTrack(\.scale) {
    // LinearKeyframe: constant-speed interpolation between values
    // Best for: opacity fades, progress bars
    LinearKeyframe(1.0, duration: 0.2)

    // SpringKeyframe: physics-based interpolation
    // Best for: bouncy overshoots, natural settling
    SpringKeyframe(1.2, duration: 0.3, spring: .bouncy)

    // CubicKeyframe: bezier-curve interpolation
    // Best for: branded easing, precise acceleration curves
    CubicKeyframe(0.95, duration: 0.15)

    // MoveKeyframe: instant jump to value (no interpolation)
    // Best for: resetting position between loops
    MoveKeyframe(1.0)
}
```

**Production example — loading dots with staggered bounce:**

```swift
struct LoadingAnimationValues {
    var yOffset: CGFloat = 0
    var scale: CGFloat = 1
}

@Equatable
struct LoadingDots: View {
    @State private var trigger = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                KeyframeAnimator(
                    initialValue: LoadingAnimationValues(),
                    trigger: trigger
                ) { values in
                    Circle()
                        .fill(.blue)
                        .frame(width: 12, height: 12)
                        .offset(y: values.yOffset)
                        .scaleEffect(values.scale)
                } keyframes: { _ in
                    KeyframeTrack(\.yOffset) {
                        // Stagger start: each dot waits before jumping
                        LinearKeyframe(0, duration: Double(index) * 0.12)
                        SpringKeyframe(-16, duration: 0.2, spring: .bouncy(duration: 0.3))
                        SpringKeyframe(0, duration: 0.25, spring: .smooth)
                    }

                    KeyframeTrack(\.scale) {
                        LinearKeyframe(1, duration: Double(index) * 0.12)
                        SpringKeyframe(1.3, duration: 0.15, spring: .snappy)
                        SpringKeyframe(1.0, duration: 0.2, spring: .smooth)
                    }
                }
            }
        }
        .onAppear { trigger.toggle() }
    }
}
```

**PhaseAnimator vs. KeyframeAnimator decision guide:**

| Criterion | PhaseAnimator | KeyframeAnimator |
|-----------|--------------|------------------|
| Properties animate together | Yes — all per phase | No — each has own timeline |
| Precise timing per property | No | Yes — millisecond control |
| Complexity | Low (enum + cases) | Medium (tracks + keyframes) |
| Continuous looping | Built-in (omit trigger) | Manual (re-trigger) |
| Best for | Simple step sequences | Branded, choreographed motion |

Reference: [WWDC 2023 — Explore SwiftUI animation](https://developer.apple.com/wwdc23/10156)
