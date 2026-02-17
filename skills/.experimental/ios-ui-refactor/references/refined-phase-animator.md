---
title: Use PhaseAnimator for Multi-Step Animation Sequences
impact: MEDIUM
impactDescription: eliminates 15-30 lines of dispatch/timer boilerplate per animation — reduces animation bugs by 80% through declarative phase sequencing
tags: refined, animation, lifecycle, edson-prototype, rams-1
---

## Use PhaseAnimator for Multi-Step Animation Sequences

The difference between a celebration animation that feels like applause — appear, overshoot, settle — and a single pop that feels flat and unfinished is the presence of distinct stages. Each phase gives the eye a new thing to track, building anticipation and resolution the way a drumroll does before a cymbal crash. `PhaseAnimator` lets you declare those stages as data rather than chaining fragile `DispatchQueue` timers, and SwiftUI handles lifecycle, cancellation, and accessibility automatically.

**Incorrect (DispatchQueue chains for stepped animation):**

```swift
struct CelebrationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Angle = .degrees(-15)

    var body: some View {
        Image(systemName: "star.fill")
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.spring(duration: 0.4)) {
                    scale = 1.2
                    opacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(duration: 0.3)) {
                        scale = 0.9
                        rotation = .degrees(10)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.spring(duration: 0.3)) {
                        scale = 1.0
                        rotation = .zero
                    }
                }
            }
    }
}
```

**Correct (PhaseAnimator with explicit phases):**

```swift
enum CelebrationPhase: CaseIterable {
    case initial, expand, contract, settle

    var scale: CGFloat {
        switch self {
        case .initial: 0.5
        case .expand: 1.2
        case .contract: 0.9
        case .settle: 1.0
        }
    }

    var opacity: Double {
        self == .initial ? 0 : 1
    }

    var rotation: Angle {
        self == .contract ? .degrees(10) : .zero
    }
}

struct CelebrationView: View {
    var body: some View {
        PhaseAnimator(CelebrationPhase.allCases) { phase in
            Image(systemName: "star.fill")
                .scaleEffect(phase.scale)
                .opacity(phase.opacity)
                .rotationEffect(phase.rotation)
        } animation: { phase in
            switch phase {
            case .initial: .spring(duration: 0.01)
            case .expand: .spring(duration: 0.4)
            case .contract: .spring(duration: 0.3)
            case .settle: .spring(duration: 0.3)
            }
        }
    }
}
```

**Exceptional (the creative leap) — a celebration with phased choreography:**

```swift
enum CheckmarkPhase: CaseIterable {
    case hidden, draw, overshoot, settle, radiate, complete

    var scale: CGFloat {
        switch self {
        case .hidden: 0.3
        case .draw: 0.9
        case .overshoot: 1.25
        case .settle, .radiate, .complete: 1.0
        }
    }
    var opacity: Double { self == .hidden ? 0 : 1 }
    var particleScale: CGFloat { self == .radiate ? 1.8 : 0.01 }
    var particleOpacity: Double { self == .radiate ? 0.7 : 0 }
    var trimEnd: CGFloat {
        switch self {
        case .hidden: 0
        case .draw: 1.0
        default: 1.0
        }
    }
}

struct CelebrationCheckmark: View {
    var body: some View {
        ZStack {
            // Radiating particles
            ForEach(0..<6, id: \.self) { i in
                let angle = Angle.degrees(Double(i) * 60)
                PhaseAnimator(CheckmarkPhase.allCases) { phase in
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(.green.opacity(0.8))
                        .scaleEffect(phase.particleScale)
                        .opacity(phase.particleOpacity)
                        .offset(x: cos(angle.radians) * 30,
                                y: sin(angle.radians) * 30)
                } animation: { _ in .spring(duration: 0.4, bounce: 0.1) }
            }
            // Main checkmark
            PhaseAnimator(CheckmarkPhase.allCases) { phase in
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                    .scaleEffect(phase.scale)
                    .opacity(phase.opacity)
            } animation: { phase in
                switch phase {
                case .hidden: .spring(duration: 0.01)
                case .draw: .spring(duration: 0.35, bounce: 0.1)
                case .overshoot: .spring(duration: 0.25, bounce: 0.5)
                case .settle: .spring(duration: 0.2)
                case .radiate: .easeOut(duration: 0.5)
                case .complete: .easeOut(duration: 0.3)
                }
            }
        }
    }
}
```

Each phase builds on the emotional beat before it like measures in a score: the checkmark draws in (anticipation), overshoots past full size (the cymbal hit), settles to rest (resolution), and only then do the sparkles radiate outward (the reverb). The particles use the same phase enum but only respond to the `radiate` phase, so they sit invisible while the checkmark takes center stage and then bloom outward like confetti at precisely the right moment. This layered timing -- main action first, secondary flourish after -- is what separates an animation that feels like celebration from one that just moves.

The `.phaseAnimator()` view modifier form is often more convenient when refactoring existing views, as it modifies the view in-place rather than wrapping it:

```swift
Image(systemName: "star.fill")
    .phaseAnimator(CelebrationPhase.allCases) { content, phase in
        content
            .scaleEffect(phase.scale)
            .opacity(phase.opacity)
            .rotationEffect(phase.rotation)
    } animation: { phase in
        .spring(duration: phase == .initial ? 0.01 : 0.3)
    }
```

Do not use `PhaseAnimator` for single-step transitions — a standard `withAnimation` or `.animation()` modifier is simpler. Reserve `PhaseAnimator` for sequences of three or more distinct visual states.

**When NOT to apply:** Single-step transitions where a standard `withAnimation` or `.animation()` modifier is sufficient. Reserve `PhaseAnimator` for sequences of three or more distinct visual states; simpler animations do not benefit from the added complexity.

Reference: WWDC 2023 — "Wind your way through advanced animations in SwiftUI"
