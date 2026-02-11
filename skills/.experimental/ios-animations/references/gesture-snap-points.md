---
title: Use Velocity-Aware Snap Points
impact: HIGH
impactDescription: snapping without velocity feels like the UI is fighting the user
tags: gesture, snap, velocity, detent, sheet
---

## Use Velocity-Aware Snap Points

When a draggable element has multiple resting positions — a bottom sheet with collapsed, half, and full detents, or a horizontal pager between cards — the snap target must factor in velocity, not just proximity. If the user is at 40% of the way to the next snap point but flicking hard in that direction, they expect to arrive there. Snapping to the nearest point by distance alone makes the UI fight the user's momentum. SwiftUI's `predictedEndLocation` projects where the gesture would land based on current velocity, making it the ideal input for snap-point selection.

**Incorrect (nearest-by-distance ignores momentum):**

```swift
struct BottomSheet: View {
    @State private var sheetOffset: CGFloat = 0

    private let detents: [CGFloat] = [0, -300, -600]
    // 0 = collapsed, -300 = half, -600 = full

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView {
                    ForEach(0..<20) { index in
                        Text("Item \(index)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 650)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .offset(y: geometry.size.height + sheetOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sheetOffset = nearestDetent(to: sheetOffset) + value.translation.height
                    }
                    .onEnded { _ in
                        // Snaps to nearest by distance only — a fast upward
                        // flick near the bottom snaps back down instead of
                        // jumping to the half detent
                        withAnimation(.smooth) {
                            sheetOffset = nearestDetent(to: sheetOffset)
                        }
                    }
            )
        }
    }

    private func nearestDetent(to offset: CGFloat) -> CGFloat {
        detents.min(by: { abs($0 - offset) < abs($1 - offset) }) ?? 0
    }
}
```

**Correct (project velocity to find the intended snap point):**

```swift
struct BottomSheet: View {
    @State private var currentDetent: CGFloat = 0
    @State private var dragOffset: CGFloat = 0

    // 0 = collapsed (hidden), -300 = half, -600 = full
    private let detents: [CGFloat] = [0, -300, -600]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView {
                    ForEach(0..<20) { index in
                        Text("Item \(index)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 650)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .offset(y: geometry.size.height + currentDetent + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        // Project the current position using predicted end
                        // translation — velocity is baked into the projection
                        let currentPosition = currentDetent + dragOffset
                        let projectedPosition = currentDetent + value.predictedEndTranslation.height

                        // Find the detent nearest to the projected landing
                        let targetDetent = detents.min(by: {
                            abs($0 - projectedPosition) < abs($1 - projectedPosition)
                        }) ?? 0

                        withAnimation(.smooth) {
                            currentDetent = targetDetent
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}
```

**A reusable snap-point projection helper:**

```swift
extension Collection where Element == CGFloat {
    /// Returns the element nearest to the projected landing position.
    /// `current` is the position before the gesture started,
    /// `predicted` is `value.predictedEndTranslation` along the relevant axis.
    func nearestSnap(from current: CGFloat, predicted: CGFloat) -> CGFloat {
        let projectedPosition = current + predicted
        return self.min(by: {
            abs($0 - projectedPosition) < abs($1 - projectedPosition)
        }) ?? current
    }
}

// Usage in .onEnded:
// let target = detents.nearestSnap(
//     from: currentDetent,
//     predicted: value.predictedEndTranslation.height
// )
```

**Benefits:**
- A fast upward flick from the collapsed position jumps straight to half or full, matching intent
- A slow drag that stops near the current detent stays put instead of lurching to the next one
- The projected-position approach works identically for vertical sheets, horizontal pagers, and dial controls
- Spring settle animation preserves the velocity from the flick, so the transition feels physically connected

Reference: [WWDC 2018 — Designing Fluid Interfaces](https://developer.apple.com/wwdc18/803), [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
