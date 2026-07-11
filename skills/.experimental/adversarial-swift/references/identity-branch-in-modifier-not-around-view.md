---
title: Fold styling conditions into modifiers instead of branching around the view
tags: identity, conditional-styling, structural-identity, state-loss
---

## Fold styling conditions into modifiers instead of branching around the view

The wrong default is wrapping the same view in an `if/else` just to vary a modifier (`if studyMode { Photo().grayscale(1) } else { Photo() }`). SwiftUI treats each branch as a distinct structural entity even when the underlying view type is the same, so toggling the condition destroys the existing view and initializes a new one — an in-flight image download or any other transient state is immediately discarded. Moving the condition inside the modifier keeps the view at a stable position in the render tree, so only its attributes change.

**Evidence of violation:** an `if/else` in a view builder where both branches construct the same root view (same type, same primary inputs) and differ only in the modifiers applied, keyed on runtime state. PASS: the condition is folded into modifier parameters (`.grayscale(isStudyMode ? 1 : 0)`) or ternaries within one chain. N/A: the branches show genuinely different views or screens — the source reserves conditional blocks for when the intent is specifically to clear a view and its associated state from the hierarchy; a reviewer claiming this carve-out must cite the differing branch content.

**Incorrect (toggling the mode destroys the photo view and its download):**

```swift
import SwiftUI

struct TrailPhotoSection: View {
    let photoName: String
    @State private var isStudyModeEnabled = false

    var body: some View {
        VStack {
            if isStudyModeEnabled {
                Image(photoName)
                    .grayscale(1.0)
                    .contrast(1.2)
            } else {
                Image(photoName)
            }

            Toggle("Study mode", isOn: $isStudyModeEnabled)
        }
    }
}
```

**Correct (stable identity — only attribute values animate):**

```swift
import SwiftUI

struct TrailPhotoSection: View {
    let photoName: String
    @State private var isStudyModeEnabled = false

    var body: some View {
        VStack {
            Image(photoName)
                .grayscale(isStudyModeEnabled ? 1.0 : 0)
                .contrast(isStudyModeEnabled ? 1.2 : 1)

            Toggle("Study mode", isOn: $isStudyModeEnabled)
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Preserving structural view identity”.
