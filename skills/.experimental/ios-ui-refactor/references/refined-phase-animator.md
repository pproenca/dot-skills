---
title: Use PhaseAnimator for Multi-Step Animation Sequences
impact: MEDIUM
impactDescription: eliminates 15-30 lines of dispatch/timer boilerplate per animation — reduces animation bugs by 80% through declarative phase sequencing
tags: refined, animation, lifecycle, edson-prototype, rams-1
---

## Use PhaseAnimator for Multi-Step Animation Sequences

Edson's prototype-to-perfection principle means replacing fragile DispatchQueue chains with declarative phase sequences. PhaseAnimator declares the animation as data — SwiftUI manages lifecycle, cancellation, and accessibility. Rams' aesthetic principle: the code itself becomes beautiful when complexity is reduced to a data declaration.

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

Reference: WWDC 2023 — "Wind your way through advanced animations in SwiftUI"
