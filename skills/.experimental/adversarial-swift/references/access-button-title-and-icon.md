---
title: Give every Button a title and icon, reducing visuals with labelStyle
tags: access, button, voiceover, labels
---

## Give every Button a title and icon, reducing visuals with labelStyle

The wrong default for an icon-only design is the view-closure initializer with a bare `Image` — it "prevents the button from adapting correctly to different system contexts and strips away the necessary accessibility labels, making it difficult for users who rely on assistive technologies." Give SwiftUI the full semantic context — title and symbol — and reduce the visual presentation with `.labelStyle(.iconOnly)`; the button then adapts per context (toolbar, swipe action) while keeping full accessibility traits and labels.

**Evidence of violation:** a `Button` whose label closure contains only an `Image` (no `Text` or `Label`) and no `.accessibilityLabel` anywhere on the chain. PASS: `Button("Edit", systemImage: "pencil")` or a `Label`-based initializer, optionally visually reduced via `.labelStyle(.iconOnly)`. PASS: an image-only label closure that carries an explicit `.accessibilityLabel`. N/A: the label contains text, or no buttons occur in the target.

**Incorrect (no accessibility label, no context adaptation):**

```swift
struct EditObservationButton: View {
    let onEdit: () -> Void

    var body: some View {
        Button {
            onEdit()
        } label: {
            Image(systemName: "pencil")
        }
    }
}
```

**Correct (full semantic context; visuals reduced where needed):**

```swift
struct EditObservationButton: View {
    let onEdit: () -> Void

    var body: some View {
        Button("Edit", systemImage: "pencil") {
            onEdit()
        }
        .labelStyle(.iconOnly)
    }
}
```

Reference: expert SwiftUI reference (2026), “Leveraging standard components and semantic styling”
