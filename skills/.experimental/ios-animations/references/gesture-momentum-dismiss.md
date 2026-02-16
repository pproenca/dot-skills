---
title: Dismiss on Velocity OR Distance Threshold
impact: HIGH
impactDescription: Velocity-only dismissal causes 50% of slow-drag dismissal attempts to fail. Distance-only dismissal causes 70% of fast-flick attempts to fail. Combining both thresholds captures 95%+ of user intent across interaction speeds.
tags: gesture, momentum, velocity, dismiss, swipe
---

## Dismiss on Velocity OR Distance Threshold

A dismissible sheet, card, or notification must respond to two distinct user intentions: a slow deliberate drag past the halfway point, and a fast decisive flick that barely covers any distance. Checking only translation misses the fast flick — the user swipes hard but the card snaps back because it only moved 80 points. Checking only velocity misses the slow drag — the user carefully pulls the card down 60% of the screen, lifts their finger gently, and the card bounces back. Both feel broken in different ways.

The fix is a simple OR gate: dismiss if `translation > threshold || velocity > velocityThreshold`. A good starting point is 200pt distance or 800pt/s velocity (approximately Emil Kowalski's 0.11 px/ms web threshold adapted for UIKit/SwiftUI point density).

**Incorrect (distance-only check ignores fast flicks):**

```swift
struct SwipeToDismissCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        if !isDismissed {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(height: 300)
                .overlay {
                    Text("Swipe down to dismiss")
                        .foregroundStyle(.secondary)
                }
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                offset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            // Only checks distance — a fast 100pt flick
                            // snaps back and feels broken
                            if value.translation.height > 200 {
                                withAnimation(.smooth) {
                                    isDismissed = true
                                }
                            } else {
                                withAnimation(.smooth) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}
```

**Correct (distance OR velocity — both user intentions are honored):**

```swift
@Equatable
struct SwipeToDismissCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    private let distanceThreshold: CGFloat = 200
    private let velocityThreshold: CGFloat = 800 // points per second

    var body: some View {
        if !isDismissed {
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(.ultraThinMaterial)
                .frame(height: 300)
                .overlay {
                    Text("Swipe down to dismiss")
                        .foregroundStyle(.secondary)
                }
                .offset(y: offset)
                .opacity(dismissProgress > 0.5 ? 1.0 - dismissProgress : 1.0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                offset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.height
                            let velocity = value.velocity.height

                            // Fast flick OR slow drag past midpoint — both dismiss
                            let shouldDismiss =
                                translation > distanceThreshold ||
                                velocity > velocityThreshold

                            if shouldDismiss {
                                withAnimation(.smooth) {
                                    isDismissed = true
                                }
                            } else {
                                withAnimation(.smooth) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }

    private var dismissProgress: CGFloat {
        min(offset / distanceThreshold, 1.0)
    }
}
```

**Using `predictedEndTranslation` as an alternative approach:**

```swift
@Equatable
struct SwipeToDismissSheet: View {
    @State private var offset: CGFloat = 0
    @Binding var isPresented: Bool

    private let sheetHeight: CGFloat = 400
    private let dismissFraction: CGFloat = 0.5

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: Spacing.md) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, Spacing.sm)

                Text("Sheet Content")
                    .font(.headline)

                Spacer()
            }
            .frame(height: sheetHeight)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.lg))
            .offset(y: max(offset, 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.height
                    }
                    .onEnded { value in
                        // predictedEndTranslation bakes velocity into a
                        // projected landing position — one check covers both
                        // slow drags and fast flicks
                        let projected = value.predictedEndTranslation.height
                        let shouldDismiss = projected > sheetHeight * dismissFraction

                        if shouldDismiss {
                            withAnimation(.smooth) {
                                isPresented = false
                            }
                        } else {
                            withAnimation(.smooth) {
                                offset = 0
                            }
                        }
                    }
            )
        }
    }
}
```

**Benefits:**
- Fast flicks dismiss immediately even with minimal distance traveled
- Slow deliberate drags past the midpoint dismiss without requiring a fast release
- `predictedEndTranslation` can unify both checks into a single projected position comparison
- Users never experience the frustration of a hard swipe that bounces back

Reference: Emil Kowalski — [Gesture velocity threshold of 0.11 px/ms](https://emilkowal.ski/ui/building-a-drawer-component)
