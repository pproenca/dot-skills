---
title: Give every Button a title and icon, reducing visuals with labelStyle
tags: access, button, voiceover, labels
---

## Give every Button a title and icon, reducing visuals with labelStyle

The wrong default for an icon-only design is the view-closure initializer with a bare `Image`. That form strips the accessibility label — assistive technologies have nothing to announce — and it prevents the button from adapting its appearance to system contexts such as toolbars and swipe actions, which render a title-and-icon button appropriately for their location. Give SwiftUI the full semantic context — title and symbol — and reduce the visual presentation with `.labelStyle(.iconOnly)`; the customization is scoped to the visuals while the button keeps full accessibility traits and labels everywhere it appears.

**Evidence of violation:** a `Button` whose label closure contains only an `Image` (no `Text` or `Label` title) and no `.accessibilityLabel` anywhere on the chain. PASS: `Button("Edit", systemImage: "pencil")` or a `Label`-based initializer, optionally visually reduced via `.labelStyle(.iconOnly)`. PASS: an image-only label closure that carries an explicit `.accessibilityLabel` — the reviewer must cite it. N/A: the label contains text, or no buttons occur in the target.

**Incorrect (no accessibility label, no context adaptation):**

```swift
import SwiftUI

struct Observation: Identifiable {
    let id = UUID()
    var note = ""
}

struct EditObservationButton: View {
    let observationID: Observation.ID

    var body: some View {
        // ⚠️ Missing the required accessibility information
        Button {
            // ... edit observation...
        } label: {
            Image(systemName: "pencil")
        }
    }
}
```

**Correct (full semantic context; visuals reduced where needed):**

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

struct ObservationRow: View {
    let observation: Observation

    var body: some View {
        Text(observation.note)
    }
}

struct ObservationList: View {
    let observations: [Observation]

    var body: some View {
        List(observations) { observation in
            ObservationRow(observation: observation)
                .swipeActions {
                    EditObservationButton(observationID: observation.id)
                        .labelStyle(.iconOnly)
                }
        }
    }
}
```
