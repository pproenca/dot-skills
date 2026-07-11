---
title: Give gesture-driven custom controls an accessibility representation
tags: access, voiceover, custom-controls, canvas
---

## Give gesture-driven custom controls an accessibility representation

The wrong default is shipping a custom control as "a collection of shapes and gestures." `Canvas` and custom drawing "does not automatically populate the accessibility tree. Without an explicit accessibility representation, the component's functionally remains entirely hidden from VoiceOver," and drag-only interaction gives AssistiveTouch users no path to increment or decrement the value. Style a system control (`ToggleStyle`, `ButtonStyle`) where a semantic match exists; otherwise attach `.accessibilityRepresentation` with the matching system control.

**Evidence of violation:** a view that mutates a `Binding` or state via gestures over `Canvas`, shapes, or custom drawing, with zero `accessibility*` modifiers. PASS: `.accessibilityRepresentation { Picker/Slider/… }`, or an equivalent explicit set of label + traits + value + adjustable actions. PASS: the custom look is a style on a system control (`ToggleStyle`, `ButtonStyle`), which inherits accessibility automatically. N/A: the drawing is purely decorative — no gesture, no bound value.

**Incorrect (functionality invisible to VoiceOver and AssistiveTouch):**

```swift
struct CircularSlider: View {
    @Binding var value: Double

    var body: some View {
        Canvas { context, size in
            // ... custom drawing code ...
        }
        .frame(width: 200, height: 200)
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { gesture in
                value = min(1, max(0, gesture.location.y / 200))
            }
        )
    }
}
```

**Correct (bespoke visuals for sighted users, a system control for assistive tech):**

```swift
struct CircularSlider: View {
    @Binding var value: Double

    var body: some View {
        Canvas { context, size in
            // ... custom drawing code ...
        }
        .frame(width: 200, height: 200)
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { gesture in
                value = min(1, max(0, gesture.location.y / 200))
            }
        )
        .accessibilityRepresentation {
            Slider(value: $value, in: 0...1) {
                Text("Level")
            }
        }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Creating custom UI elements that fit within the system”
