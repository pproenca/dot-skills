---
title: Use PhaseAnimator for Multi-Step Sequences
impact: MEDIUM
impactDescription: eliminates 15-30 lines of DispatchQueue chaining per multi-step sequence — phases are declarative, cancellable, and accessibility-aware without manual bookkeeping
tags: orch, phaseAnimator, sequence, multi-step, declarative
---

## Use PhaseAnimator for Multi-Step Sequences

Multi-step animation sequences — appear, scale up, settle, then pulse — are common in onboarding flows, success states, and attention-drawing UI. The imperative approach chains `DispatchQueue.main.asyncAfter` calls, each updating a `@State` property at a calculated delay. This creates fragile, hard-to-maintain code: timing values are scattered across closures, cancellation requires manual bookkeeping, and adding or reordering steps means recalculating every subsequent delay.

`PhaseAnimator` (iOS 17+) replaces all of this with a declarative phase list. You define an enum conforming to `CaseIterable` where each case provides the visual properties for that phase. SwiftUI steps through phases sequentially, applying the specified animation between each pair. The result is a multi-step sequence in ~10 lines that is cancellable, restartable, and automatically respects reduce-motion preferences.

**Incorrect (chained DispatchQueue.main.asyncAfter — fragile timing):**

```swift
struct CelebrationBadge: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -15

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 64))
            .foregroundStyle(.yellow)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                // Step 1: fade in small
                withAnimation(.smooth(duration: 0.2)) {
                    opacity = 1
                }
                // Step 2: scale up and rotate (must calculate cumulative delay)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                        scale = 1.2
                        rotation = 5
                    }
                }
                // Step 3: settle to normal (cumulative delay grows)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.smooth(duration: 0.3)) {
                        scale = 1.0
                        rotation = 0
                    }
                }
                // Adding a step here means recalculating all subsequent delays.
                // Navigating away mid-sequence leaks the pending closures.
            }
    }
}
```

**Correct (PhaseAnimator — declarative multi-step sequence):**

```swift
@Equatable
struct CelebrationBadge: View {
    @State private var animationTrigger = false

    enum AnimationPhase: CaseIterable {
        case initial, scaleUp, settle

        var scale: CGFloat {
            switch self {
            case .initial: return 0.5
            case .scaleUp: return 1.2
            case .settle: return 1.0
            }
        }

        var opacity: Double { self == .initial ? 0 : 1 }

        var rotation: Double {
            switch self {
            case .initial: return -15
            case .scaleUp: return 5
            case .settle: return 0
            }
        }

        var animation: Animation {
            switch self {
            case .initial: return .smooth(duration: 0.2)
            case .scaleUp: return .spring(duration: 0.4, bounce: 0.3)
            case .settle: return .smooth(duration: 0.3)
            }
        }
    }

    var body: some View {
        PhaseAnimator(AnimationPhase.allCases, trigger: animationTrigger) { phase in
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
                .scaleEffect(phase.scale)
                .opacity(phase.opacity)
                .rotationEffect(.degrees(phase.rotation))
        } animation: { phase in
            phase.animation
        }
        .onAppear { animationTrigger.toggle() }
    }
}
```

**Continuous looping with PhaseAnimator (no trigger — runs forever):**

```swift
@Equatable
struct PulsingIndicator: View {
    enum PulsePhase: CaseIterable {
        case resting
        case expanded

        var scale: CGFloat {
            switch self {
            case .resting: return 1.0
            case .expanded: return 1.15
            }
        }

        var opacity: Double {
            switch self {
            case .resting: return 0.6
            case .expanded: return 1.0
            }
        }
    }

    var body: some View {
        // No trigger parameter = continuous loop
        PhaseAnimator(PulsePhase.allCases) { phase in
            Circle()
                .fill(.blue)
                .frame(width: 12, height: 12)
                .scaleEffect(phase.scale)
                .opacity(phase.opacity)
        } animation: { phase in
            switch phase {
            case .resting: return .smooth(duration: 0.8)
            case .expanded: return .smooth(duration: 0.8)
            }
        }
    }
}
```

**Modifier form (.phaseAnimator) for inline use:**

```swift
@Equatable
struct NotificationBell: View {
    @State private var hasNotification = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.title2)
            .foregroundStyle(hasNotification ? .yellow : .secondary)
            .phaseAnimator(
                [0.0, -15.0, 15.0, -10.0, 10.0, 0.0],
                trigger: hasNotification
            ) { content, angle in
                content
                    .rotationEffect(.degrees(angle))
            } animation: { _ in
                .snappy(duration: 0.15)
            }
            .onTapGesture {
                hasNotification.toggle()
            }
    }
}
```

**When to use PhaseAnimator vs. other tools:**

| Scenario | Use |
|----------|-----|
| 2-4 sequential steps with different animations | `PhaseAnimator` |
| Precise millisecond timing per property | `KeyframeAnimator` |
| Single state toggle | `.animation()` modifier |
| Continuous frame-level animation | `TimelineView` |

**Note:** do not use `PhaseAnimator` for single-step transitions — it adds unnecessary complexity. A simple `.animation(.smooth, value: state)` is clearer for one-step changes.

**For complex animation state with business logic:** When animation phases are triggered by data loading, user actions, or other business logic, extract animation state into an `@Observable` ViewModel per `swift-ui-architect` constraints. Keep `@State` for view-owned animation triggers like `animationTrigger` booleans.

Reference: [WWDC 2023 — Explore SwiftUI animation](https://developer.apple.com/wwdc23/10156)
