---
title: Use GestureState for Transient Drag State
impact: MEDIUM-HIGH
impactDescription: Manual state reset via .onEnded misses 100% of system-cancelled gestures (incoming calls, alerts, gesture conflicts). @GestureState guarantees cleanup in all cases, eliminating stuck UI states and reducing reset boilerplate by 4-6 lines per gesture.
tags: gesture, GestureState, transient, drag, reset
---

## Use GestureState for Transient Drag State

`@GestureState` is a property wrapper designed for values that only exist while a gesture is active — drag offsets, press scales, rotation angles. When the gesture ends (finger lifts, cancels, or the system interrupts), `@GestureState` automatically resets to its initial value, using whatever animation is set in the transaction. This eliminates the `.onEnded` boilerplate of manually resetting state and — more importantly — guarantees cleanup even if the gesture is cancelled by the system (incoming call, gesture recognizer conflict), which `.onEnded` does not handle.

Use `@State` only when you need the gesture's final value to persist after the finger lifts (e.g., repositioning an element permanently).

**Incorrect (manual reset in `.onEnded` — misses system cancellations):**

```swift
struct DraggableChip: View {
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Text("Drag me")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.blue, in: Capsule())
            .foregroundStyle(.white)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        // Problem 1: If the system cancels the gesture
                        // (incoming call, another recognizer wins), .onEnded
                        // never fires and the chip stays offset permanently.
                        // Problem 2: Must manually specify the reset animation.
                        withAnimation(.smooth) {
                            dragOffset = .zero
                        }
                    }
            )
    }
}
```

**Correct (`@GestureState` auto-resets — even on system cancellation):**

```swift
@Equatable
struct DraggableChip: View {
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        Text("Drag me")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(.tint, in: Capsule())
            .foregroundStyle(.white)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, transaction in
                        state = value.translation
                        transaction.animation = .smooth
                    }
            )
        // No .onEnded needed — when the finger lifts (or the gesture
        // is cancelled for any reason), dragOffset resets to .zero
        // with the .smooth spring animation from the transaction.
    }
}
```

**Combining `@GestureState` for transient offset with `@State` for final position:**

```swift
@Equatable
struct RepositionableSticker: View {
    @State private var position: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 44))
            .foregroundStyle(.yellow)
            .offset(
                x: position.width + dragOffset.width,
                y: position.height + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, transaction in
                        // Transient: tracks finger during drag, resets on lift
                        state = value.translation
                        transaction.animation = .smooth
                    }
                    .onEnded { value in
                        // Persistent: commits the final translation to position
                        position.width += value.translation.width
                        position.height += value.translation.height
                    }
            )
    }
}
```

**Press-and-hold scale feedback using `@GestureState`:**

```swift
@Equatable
struct PressableButton: View {
    @GestureState private var isPressed = false

    var body: some View {
        Text("Hold me")
            .font(.headline)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(.tint, in: RoundedRectangle(cornerRadius: Radius.sm))
            .foregroundStyle(.white)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.snappy, value: isPressed)
            .gesture(
                LongPressGesture(minimumDuration: .infinity)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
        // isPressed auto-resets to false when the finger lifts.
        // The .snappy animation drives both the press-down and release.
    }
}
```

**When to use each wrapper:**

| Wrapper | Resets on end | Handles cancellation | Use case |
|---------|:---:|:---:|----------|
| `@GestureState` | Automatic | Yes | Drag offset that snaps back, press scale, rotation preview |
| `@State` | Manual | No (`.onEnded` only) | Final repositioned location, committed swipe action |

**Benefits:**
- Zero boilerplate for snap-back gestures — no `.onEnded` reset logic needed
- System cancellations (calls, alerts, gesture conflicts) always clean up properly
- The transaction animation applies both during the gesture and on the auto-reset
- Combining `@GestureState` (transient) with `@State` (persistent) handles the full spectrum of gesture patterns
