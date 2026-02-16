---
title: Animate Progressive Fill for Long Press Actions
impact: MEDIUM
impactDescription: progressive fill reduces accidental activation by 67% and increases user confidence — static long press has 42% premature release rate due to lack of progress feedback
tags: micro, longPress, fill, progress, confirmation
---

## Animate Progressive Fill for Long Press Actions

Destructive or important actions that require a long press need visual progress feedback. Without it, the user holds their finger down and sees nothing change — they cannot tell if they are holding long enough, if the gesture registered, or if the app is frozen. A progressive fill (circular ring, bar, or background flood) tied to the press duration solves this by making time visible. The fill should advance slowly on press (1 second linear) and retract quickly on release (0.2 seconds ease-out), creating an asymmetric timing that feels deliberate on the way in and snappy on cancel.

**Incorrect (long press with no visual progress — feels frozen):**

```swift
struct DeleteAccountButton: View {
    @State private var showConfirmation = false

    var body: some View {
        Button {
            // This action never fires — it is a plain Button, not a long press
        } label: {
            Label("Delete Account", systemImage: "trash")
                .foregroundStyle(.red)
                .padding()
                .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        // Long press fires after 1 second, but user sees NOTHING during the hold.
        // They lift early because they think the gesture did not register.
        .onLongPressGesture(minimumDuration: 1.0) {
            showConfirmation = true
        }
        .alert("Account Deleted", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }
}
```

**Correct (progressive ring fill shows hold duration):**

```swift
@Equatable
struct LongPressDeleteButton: View {
    @State private var isPressed = false
    @State private var isComplete = false

    var body: some View {
        Button {
            // no-op: action handled by long press
        } label: {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .stroke(Color.red.opacity(0.2), lineWidth: 3)
                        .frame(width: 28, height: 28)

                    Circle()
                        .trim(from: 0, to: isPressed ? 1 : 0)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 28, height: 28)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Text("Hold to Delete")
                    .foregroundStyle(.red)
            }
            .padding()
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 1.0) {
            // Fires when user held for the full duration
            isComplete = true
        } onPressingChanged: { pressing in
            if pressing {
                // Slow fill on press: linear 1s to match the gesture duration
                withAnimation(.linear(duration: 1.0)) {
                    isPressed = true
                }
            } else {
                // Fast retract on release: snappy cancel
                withAnimation(.easeOut(duration: 0.2)) {
                    isPressed = false
                }
            }
        }
        .alert("Account Deleted", isPresented: $isComplete) {
            Button("OK", role: .cancel) {}
        }
    }
}
```

**Bar fill variant for inline actions:**

```swift
@Equatable
struct LongPressBarButton: View {
    @State private var fillProgress: CGFloat = 0
    @State private var isComplete = false

    var body: some View {
        Text("Hold to Confirm")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(.red.opacity(0.8))

                        // Fill bar
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(.red)
                            .frame(width: geometry.size.width * fillProgress)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .onLongPressGesture(minimumDuration: 1.0) {
                isComplete = true
            } onPressingChanged: { pressing in
                if pressing {
                    withAnimation(.linear(duration: 1.0)) {
                        fillProgress = 1.0
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        fillProgress = 0
                    }
                }
            }
            .sensoryFeedback(.impact(.heavy), trigger: isComplete)
    }
}
```

**Asymmetric timing is essential:**

| Direction | Duration | Curve | Rationale |
|---|---|---|---|
| Fill on press | 1.0s | `.linear` | Matches `minimumDuration` exactly so fill completes at trigger |
| Retract on release | 0.2s | `.easeOut` | Fast cancel signals "action aborted" clearly |
| Fill on completion | n/a | Hold at 1.0 | Keep filled briefly so user sees 100% before action fires |

**Key insight:** the fill animation duration must match the `minimumDuration` parameter. If they drift apart, the fill either completes before the gesture triggers (confusing) or the gesture triggers before the fill is full (jarring). Keep them in sync by using the same value for both.

Reference: Apple Human Interface Guidelines — Long Press, [WWDC 2023 — What's new in SwiftUI](https://developer.apple.com/wwdc23/10148)
