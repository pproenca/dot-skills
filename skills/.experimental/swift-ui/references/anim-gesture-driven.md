---
title: Make Animations Gesture-Driven
impact: MEDIUM-HIGH
impactDescription: creates interactive, responsive feel
tags: anim, gesture, drag, interactive, responsive
---

## Make Animations Gesture-Driven

Gesture-driven animations respond to user input in real-time. The view follows the finger, then settles into place when released.

**Incorrect (toggle-based, not interactive):**

```swift
struct DismissibleCard: View {
    @State private var isDismissed = false

    var body: some View {
        CardContent()
            .offset(x: isDismissed ? 300 : 0)
            .onTapGesture {
                withAnimation { isDismissed = true }  // Not draggable
            }
    }
}
```

**Correct (gesture-driven with spring settle):**

```swift
struct DismissibleCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        CardContent()
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation.width  // Follow finger
                    }
                    .onEnded { gesture in
                        let threshold: CGFloat = 100
                        if gesture.translation.width > threshold {
                            // Dismiss with velocity
                            withAnimation(.spring()) {
                                offset = 500
                                isDismissed = true
                            }
                        } else {
                            // Snap back
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
    }
}
```

**Sheet-like drag to dismiss:**

```swift
struct InteractiveSheet: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack { /* content */ }
            .offset(y: max(0, dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { dragOffset = $0.translation.height }
                    .onEnded { gesture in
                        if gesture.translation.height > 150 ||
                           gesture.predictedEndTranslation.height > 300 {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}
```

**Using predictedEndTranslation for natural feel:**

```swift
// Consider velocity, not just position
if gesture.predictedEndTranslation.height > 300 {
    dismiss()  // User flicked quickly
}
```

Reference: [Human Interface Guidelines - Gestures](https://developer.apple.com/design/human-interface-guidelines/gestures)
