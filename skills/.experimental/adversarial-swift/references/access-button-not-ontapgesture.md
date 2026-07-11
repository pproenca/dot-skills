---
title: Use Button for tap-activated actions, not onTapGesture on plain views
tags: access, button, gestures, traits
---

## Use Button for tap-activated actions, not onTapGesture on plain views

The wrong default is faking a control with `Image(...).onTapGesture { action }`. A manual implementation "fails to provide standard visual feedback, such as the system-expected highlight state when pressed, and lacks the inherent accessibility traits that identify the element as an interactive control" — VoiceOver users never learn the element is tappable, and the element feels disconnected from the system. A real `Button` inherits highlight states, haptics, context adaptation, and accessibility for free.

**Evidence of violation:** `.onTapGesture` attached to an `Image`, `Text`, or shape performing a single activate-style action — mutating state, navigating, presenting — with no button or accessibility traits. PASS: a real `Button`, `Toggle`, `NavigationLink`, or another native control. N/A: genuinely gestural interactions (drag on a canvas, multi-touch, tap-location handling), or a tap handler whose non-control nature a comment on the gesture justifies — absent that evidence, fail closed.

**Incorrect (no highlight state, invisible to assistive technologies as a control):**

```swift
struct EditObservationButton: View {
    let onEdit: () -> Void

    var body: some View {
        Image(systemName: "pencil")
            .onTapGesture {
                onEdit()
            }
    }
}
```

**Correct (system control with traits, feedback, and context adaptation):**

```swift
struct EditObservationButton: View {
    let onEdit: () -> Void

    var body: some View {
        Button("Edit", systemImage: "pencil") {
            onEdit()
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Leveraging standard components and semantic styling”
