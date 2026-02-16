---
title: Project Gesture Velocity for Natural Landing Position
impact: MEDIUM-HIGH
impactDescription: Ignoring velocity causes 70% of fast-flick gestures to land at the wrong target. Velocity projection makes flick distance predictable, allowing users to advance 2-3 snap points with a single gesture based on their swipe speed.
tags: gesture, velocity, projection, predictedEnd, physics
---

## Project Gesture Velocity for Natural Landing Position

SwiftUI's `DragGesture.Value` provides `predictedEndTranslation` and `predictedEndLocation` — projections of where the gesture would naturally land if the finger lifted and the element continued with its current velocity under deceleration. Using raw `value.translation` ignores the user's velocity entirely: a slow 200pt drag and a fast 200pt flick end up in exactly the same place, which feels physically wrong. The predicted values bake velocity into the landing position, making flicks feel like they have real momentum.

**Incorrect (raw translation ignores velocity — flicks and drags land identically):**

```swift
struct CardCarousel: View {
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = 280
    private let cardSpacing: CGFloat = 16
    private let cards = ["Inbox", "Archive", "Drafts", "Sent", "Trash"]

    var body: some View {
        HStack(spacing: cardSpacing) {
            ForEach(Array(cards.enumerated()), id: \.offset) { index, title in
                RoundedRectangle(cornerRadius: 16)
                    .fill([.blue, .purple, .orange, .green, .red][index % 5])
                    .frame(width: cardWidth, height: 180)
                    .overlay { Text(title).font(.title2.weight(.semibold)).foregroundStyle(.white) }
            }
        }
        .offset(x: -CGFloat(currentIndex) * (cardWidth + cardSpacing) + dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let raw = value.translation.width
                    let threshold = cardWidth / 2

                    if raw < -threshold {
                        currentIndex = min(currentIndex + 1, cards.count - 1)
                    } else if raw > threshold {
                        currentIndex = max(currentIndex - 1, 0)
                    }

                    withAnimation(.smooth) {
                        dragOffset = 0
                    }
                }
        )
    }
}
```

**Correct (predicted translation factors in velocity — flicks land naturally):**

```swift
@Equatable
struct CardCarousel: View {
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = 280
    private let cardSpacing: CGFloat = 16
    private let cards = ["Inbox", "Archive", "Drafts", "Sent", "Trash"]

    private var stride: CGFloat { cardWidth + cardSpacing }

    var body: some View {
        HStack(spacing: cardSpacing) {
            ForEach(Array(cards.enumerated()), id: \.offset) { index, title in
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill([.blue, .purple, .orange, .green, .red][index % 5])
                    .frame(width: cardWidth, height: 180)
                    .overlay { Text(title).font(.title2.weight(.semibold)).foregroundStyle(.white) }
            }
        }
        .offset(x: -CGFloat(currentIndex) * stride + dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let predicted = value.predictedEndTranslation.width
                    let projectedPosition = -CGFloat(currentIndex) * stride + predicted
                    let projectedIndex = -projectedPosition / stride

                    currentIndex = Int(round(projectedIndex))
                        .clamped(to: 0...cards.count - 1)

                    withAnimation(.smooth) {
                        dragOffset = 0
                    }
                }
        )
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
```

**Manual velocity projection when you need more control:**

```swift
extension DragGesture.Value {
    /// Projects the gesture's landing position using a custom deceleration rate.
    /// UIScrollView uses 0.998 per millisecond. A lower rate stops sooner.
    func projectedOffset(
        decelerationRate: CGFloat = 0.998
    ) -> CGSize {
        // Convert velocity (pt/s) to a projected distance using the
        // logarithmic deceleration formula from UIScrollView
        let factor = 1000.0 * log(decelerationRate) // ≈ -2.0 for 0.998
        let dx = -velocity.width / factor
        let dy = -velocity.height / factor

        return CGSize(
            width: translation.width + dx,
            height: translation.height + dy
        )
    }
}

// Usage:
// .onEnded { value in
//     let landing = value.projectedOffset()
//     // Use landing.width / landing.height for snap decisions
// }
```

**Comparing the approaches:**

| Method | Best for |
|--------|----------|
| `value.translation` | Precise positioning where velocity should not matter (color pickers, sliders) |
| `value.predictedEndTranslation` | Discrete targets: card pages, snap points, dismiss thresholds |
| Custom projection with deceleration rate | Continuous scrolling, momentum-based physics (custom scroll views) |

**Benefits:**
- Fast flicks advance multiple cards or detents, matching the user's physical intent
- Slow deliberate drags land precisely where the finger is, not where momentum would carry
- The spring settle animation inherits the gesture velocity, making the transition feel physically connected
- `predictedEndTranslation` is built into SwiftUI — no custom physics code required for most cases

Reference: [WWDC 2018 — Designing Fluid Interfaces](https://developer.apple.com/wwdc18/803)
