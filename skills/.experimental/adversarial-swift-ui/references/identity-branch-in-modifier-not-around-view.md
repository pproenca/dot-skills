---
title: Fold styling conditions into modifier values instead of branching around the view
tags: identity, conditional-styling, structural-identity, state-loss
---

## Fold styling conditions into modifier values instead of branching around the view

The wrong default is wrapping the same view in an `if/else` just to vary a modifier (`if isStudyModeEnabled { BirdPhotoView(bird: bird).grayscale(1.0) } else { BirdPhotoView(bird: bird) }`). SwiftUI treats each branch as a distinct structural entity even when the underlying view type is the same, so toggling the condition forces the framework to destroy the existing view and initialize a new one — transient state such as an in-flight image download is immediately discarded. Moving the condition inside the modifier keeps the view at a stable position in the render tree, so only its attribute values change, which also enables smooth animations between the two states.

**Evidence of violation:** an `if/else` in a view builder, keyed on runtime state (`@State`, `@Binding`, a stored property, or a changeable `@Environment` value), where both branches construct the same root view type with the same primary inputs and differ only in the modifiers applied. PASS: the condition is folded into modifier parameters or ternaries within one stable chain (`.grayscale(isStudyModeEnabled ? 1.0 : 0)`, `.bold(flag)`). N/A: the branches contain genuinely different views or screens — that is a structural change, not a styling change. Carve-out: the source reserves conditional blocks for when the intent is specifically to clear a view and its associated state from the hierarchy; claiming it requires a comment at the branch citing that intent, and a carve-out asserted without that citable evidence fails closed.

**Incorrect (toggling study mode destroys the photo view and its in-flight download):**

```swift
import SwiftUI

struct Bird {
    var name: String
    var imageName: String
}

struct BirdPhotoView: View {
    let bird: Bird

    var body: some View {
        Image(bird.imageName)
            .resizable()
            .scaledToFit()
    }
}

struct BirdIdentificationInfo: View {
    let bird: Bird

    var body: some View {
        Text(bird.name)
    }
}

struct BirdDetailView: View {
    let bird: Bird
    @State private var isStudyModeEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ⚠️ Resets view identity for a style change
            if isStudyModeEnabled {
                BirdPhotoView(bird: bird)
                    .grayscale(1.0)
                    .contrast(1.2)
            } else {
                BirdPhotoView(bird: bird)
            }

            BirdIdentificationInfo(bird: bird)

            Toggle("Identification Study Mode", isOn: $isStudyModeEnabled)
                .toggleStyle(.switch)
        }
        .padding()
    }
}
```

**Correct (stable identity — only attribute values change, and they can animate):**

```swift
import SwiftUI

struct Bird {
    var name: String
    var imageName: String
}

struct BirdPhotoView: View {
    let bird: Bird

    var body: some View {
        Image(bird.imageName)
            .resizable()
            .scaledToFit()
    }
}

struct BirdIdentificationInfo: View {
    let bird: Bird

    var body: some View {
        Text(bird.name)
    }
}

struct BirdDetailView: View {
    let bird: Bird
    @State private var isStudyModeEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            BirdPhotoView(bird: bird)
                .grayscale(isStudyModeEnabled ? 1.0 : 0)
                .contrast(isStudyModeEnabled ? 1.2 : 1)

            BirdIdentificationInfo(bird: bird)

            Toggle("Identification Study Mode", isOn: $isStudyModeEnabled)
                .toggleStyle(.switch)
        }
        .padding()
    }
}

extension View {
    func highlighted(_ isHighlighted: Bool = true) -> some View {
        self
            .bold(isHighlighted)
            .underline(isHighlighted)
            .foregroundStyle(isHighlighted ? .green : .primary)
    }
}
```
