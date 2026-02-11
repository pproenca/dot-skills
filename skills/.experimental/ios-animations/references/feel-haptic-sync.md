---
title: Sync Haptic Feedback to Visual Animation Keyframes
impact: HIGH
impactDescription: haptics that arrive 50ms before or after the visual peak feel disconnected and cheap
tags: feel, haptic, sensoryFeedback, timing, sync
---

## Sync Haptic Feedback to Visual Animation Keyframes

Haptic feedback must fire at the exact moment of visual impact — not at the start of the animation, not at the end, but at the perceptual peak. When a toggle snaps into place, the haptic fires at the snap point. When a card drops into position, the haptic fires on landing. A 50ms gap between visual and tactile feedback is enough to break the illusion — the two feel like separate events instead of one unified interaction.

**Incorrect (haptic fires before the animation starts — disconnected):**

```swift
struct FavoriteButton: View {
    @State private var isFavorite = false

    var body: some View {
        Button {
            // Haptic fires HERE, before the visual animation begins
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                isFavorite.toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorite ? .red : .gray)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
        }
    }
}
```

**Correct (haptic synchronized with visual state change using sensoryFeedback):**

```swift
struct FavoriteButton: View {
    @State private var isFavorite = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                isFavorite.toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorite ? .red : .gray)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
        }
        // Haptic fires when isFavorite changes — synchronized with the visual snap
        .sensoryFeedback(.impact(weight: .medium), trigger: isFavorite)
    }
}
```

**Incorrect (manual haptic on drag end — fires at wrong moment):**

```swift
struct DismissableCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
            .frame(height: 200)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.height
                    }
                    .onEnded { value in
                        // Haptic fires immediately on finger lift
                        // but the card hasn't landed yet
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()

                        if value.translation.height > 200 {
                            withAnimation(.spring) {
                                isDismissed = true
                            }
                        } else {
                            withAnimation(.spring(bounce: 0.3)) {
                                offset = 0
                            }
                        }
                    }
            )
    }
}
```

**Correct (haptic fires at the moment of commitment — when the decision is made):**

```swift
struct DismissableCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false
    @State private var didSnap = false

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
            .frame(height: 200)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > 200 {
                            withAnimation(.spring) {
                                isDismissed = true
                            }
                            didSnap.toggle()
                        } else {
                            withAnimation(.spring(bounce: 0.3)) {
                                offset = 0
                            }
                            didSnap.toggle()
                        }
                    }
            )
            // Haptic fires when didSnap changes — at the moment the gesture
            // decides to dismiss or snap back, not after the spring settles
            .sensoryFeedback(.impact(weight: .heavy), trigger: didSnap)
    }
}
```

**Correct (different haptic types for different interactions):**

```swift
struct InteractiveListRow: View {
    @State private var isComplete = false
    @State private var deleteConfirmed = false

    var body: some View {
        HStack {
            Button {
                withAnimation(.snappy) {
                    isComplete.toggle()
                }
            } label: {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isComplete ? .green : .secondary)
            }
            // .success for completing a task — two taps, feels rewarding
            .sensoryFeedback(.success, trigger: isComplete)

            Text("Buy groceries")
                .strikethrough(isComplete)

            Spacer()

            Button {
                withAnimation(.snappy) {
                    deleteConfirmed = true
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            // .warning for destructive action — sharp buzz, feels consequential
            .sensoryFeedback(.warning, trigger: deleteConfirmed)
        }
        .padding()
    }
}
```

**Haptic type guide:**

| Haptic Type | When to Use | Feel |
|---|---|---|
| `.impact(weight: .light)` | Button taps, small toggles | Subtle tick |
| `.impact(weight: .medium)` | Favorites, selections | Solid tap |
| `.impact(weight: .heavy)` | Card drops, snaps into place | Thud |
| `.selection` | Scrolling through picker values | Soft detent |
| `.success` | Task completion, save confirmed | Double-tap, rewarding |
| `.warning` | Delete confirmation, destructive action | Sharp buzz |
| `.error` | Validation failure, blocked action | Triple-buzz, alarming |

**Key principle:** Use `.sensoryFeedback(_:trigger:)` (iOS 17+) instead of manually creating `UIImpactFeedbackGenerator`. The SwiftUI modifier fires the haptic when the trigger value changes, which is inherently synchronized with the state change driving the visual animation. Manual generators require you to time the call yourself, which almost always drifts.

**Reference:** Apple Human Interface Guidelines — "Playing haptics" section emphasizes that haptic timing must align with visual feedback. WWDC 2023 introduced `.sensoryFeedback` specifically to solve the synchronization problem.
