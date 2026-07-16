---
title: Use Button for tap-activated actions, not onTapGesture on plain views
tags: access, button, gestures, traits
---

## Use Button for tap-activated actions, not onTapGesture on plain views

The wrong default is faking a control with `Image(...).onTapGesture { action }`. The manual implementation provides no standard visual feedback — the system-expected highlight state when pressed never appears — and it lacks the accessibility traits that identify the element as an interactive control, so VoiceOver users never learn the element is tappable. The element feels disconnected from the rest of the system and needs significant extra code to reach even basic parity with a native control. A real `Button` inherits highlight states, haptics, context adaptation, and accessibility for free.

**Evidence of violation:** `.onTapGesture` attached to an `Image`, `Text`, or shape performing a single activate-style action — mutating state, navigating, presenting — with no button or accessibility traits. PASS: a real `Button`, `Toggle`, `NavigationLink`, or another native control. N/A: genuinely gestural interactions (drag on a canvas, multi-touch, tap-location handling), or a tap handler whose non-control nature is citable from the code or a comment on the gesture (e.g. dismissing keyboard focus on a background) — absent that evidence, fail closed.

**Incorrect (no highlight state, invisible to assistive technologies as a control):**

```swift
import SwiftUI

struct Observation: Identifiable {
    let id = UUID()
    var note = ""
}

struct EditObservationButton: View {
    let observationID: Observation.ID

    var body: some View {
        // ⚠️ Lacks the necessary state handling and accessibility traits
        Image(systemName: "pencil")
            .onTapGesture {
                // ... edit observation...
            }
    }
}
```

**Correct (system control with traits, feedback, and context adaptation):**

```swift
import SwiftUI

struct Observation: Identifiable {
    let id = UUID()
    var note = ""
}

struct EditObservationButton: View {
    let observationID: Observation.ID

    var body: some View {
        Button("Edit", systemImage: "pencil") {
            // ... edit observation...
        }
    }
}
```
