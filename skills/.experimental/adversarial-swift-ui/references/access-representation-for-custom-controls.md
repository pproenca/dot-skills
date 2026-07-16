---
title: Give gesture-driven custom controls an accessibility representation
tags: access, voiceover, custom-controls, canvas
---

## Give gesture-driven custom controls an accessibility representation

The wrong default is shipping a bespoke control as a collection of shapes and gestures. `Canvas` provides a high-performance drawing surface but, unlike standard SwiftUI components, does not populate the accessibility tree at all — without an explicit representation the control's functionality is entirely hidden from VoiceOver. And a drag-only interaction gives AssistiveTouch users no path to the value: the system has no way to map standard increment and decrement actions onto custom gesture logic. When no style protocol exists for the control's role, attach `.accessibilityRepresentation` mirroring the matching system control, so sighted users get the bespoke visuals while assistive technologies interact with a standard element.

**Evidence of violation:** a view that mutates a `Binding` or state via gestures over `Canvas`, shapes, or custom drawing, with zero `accessibility*` modifiers — the absence is the violation; a bespoke control with no accessibility surface is FAIL, not N/A. PASS: `.accessibilityRepresentation { Slider/Picker/… }`, or an equivalent explicit set of label + traits + value + adjustable actions. PASS: the custom look is a style on a system control (`ToggleStyle`, `ButtonStyle`), which inherits accessibility automatically. N/A: the drawing is purely decorative — no gesture, no bound value — or no bespoke controls occur in the target.

**Incorrect (functionality invisible to VoiceOver and AssistiveTouch):**

```swift
import SwiftUI

struct CircularSlider: View {
    @Binding var value: Double

    var body: some View {
        // ⚠️ No accessibility information or adaptations
        Canvas { context, size in
            // ... custom drawing code ...
        }
        .frame(width: 200, height: 200)
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { gesture in
                updateValue(with: gesture.location, in: CGSize(width: 200, height: 200))
            }
        )
    }

    private func updateValue(with location: CGPoint, in size: CGSize) {
        // ... update value ...
    }
}
```

**Correct (bespoke visuals for sighted users, a system control for assistive tech):**

```swift
import SwiftUI

enum SegmentedControlState: String, CaseIterable, Identifiable {
    case weather
    case access

    var id: Self { self }
}

struct SegmentedControl: View {
    let titleKey: LocalizedStringKey
    @Binding var selection: SegmentedControlState

    var body: some View {
        HStack {
            ForEach(SegmentedControlState.allCases) { selection in
                Button {
                    self.selection = selection
                } label: {
                    // ... custom label ...
                }
            }
        }
        .accessibilityRepresentation {
            Picker(titleKey, selection: $selection) {
                ForEach(SegmentedControlState.allCases) { selection in
                    Button {
                        self.selection = selection
                    } label: {
                        Text(selection.rawValue)
                    }
                }
            }
            .labelsHidden()
        }
    }
}
```
