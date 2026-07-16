---
title: Keep the system Back button on pushed views
tags: nav, back-button, toolbar, gestures
---

## Keep the system Back button on pushed views

The wrong default when a design wants custom chrome is `.navigationBarBackButtonHidden(true)` plus a hand-rolled chevron or a button labeled "Back". The replacement silently drops what the system button carries: the previous screen's title, the long-press history menu, and — because hiding the button often detaches the edge-swipe gesture — the swipe-back everyone navigates with. A pushed view keeps the standard Back button untouched; custom leading items belong only in modal flows that substitute explicit step controls.

**Evidence of violation:** `.navigationBarBackButtonHidden(true)` on a pushed destination, or a leading `ToolbarItem` whose label is the text "Back" or a bare `chevron.backward`/`chevron.left` image calling `dismiss()`. Carve-out: a multistep flow inside a `.sheet`/`.fullScreenCover` that replaces the button with explicit Cancel and per-step controls — the reviewer must cite the enclosing modal presentation; absent that evidence, fail closed. PASS: pushed views with the default Back button untouched — cite a pushed destination and the absence of overrides. N/A: no pushed destinations in the target.

**Incorrect (a hand-rolled Back button loses the history menu and edge swipe):**

```swift
import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        WorkoutSummaryView(workout: workout)
            .navigationTitle(workout.name)
            // ⚠️ Hides the system Back button and rebuilds a worse one
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
    }
}
```

**Correct (the system button keeps its title, menu, and gesture):**

```swift
import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        WorkoutSummaryView(workout: workout)
            .navigationTitle(workout.name)
    }
}
```

Reference: [HIG — Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
