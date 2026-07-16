---
title: Never lock the color scheme or offer an in-app appearance switch
tags: craft, dark-mode, color-scheme, appearance
---

## Never lock the color scheme or offer an in-app appearance switch

The wrong default when dark mode wasn't budgeted for is to pin the app light with `.preferredColorScheme(.light)` (or `UIUserInterfaceStyle` in Info.plist), or to "solve" appearance with an in-app light/dark toggle. The HIG rejects both: people choose an appearance systemwide — per device, per schedule — and an app that ignores that choice looks broken next to every other app on the device, while an app-specific appearance setting duplicates a system control and desynchronizes from it. The app adapts through semantic colors and variants; the user's setting decides.

**Evidence of violation:** `.preferredColorScheme(.light)`/`.dark` applied at app or root-view scope; `overrideUserInterfaceStyle` assigned a fixed style; a `UIUserInterfaceStyle` key in Info.plist; or a settings screen offering appearance modes (Light/Dark/System pickers or equivalent toggle) — cite the modifier, key, or control. PASS: no scheme override anywhere and no in-app appearance control — the reviewer must state where they checked (root scene, Info.plist, settings surfaces). N/A: a deliberately single-appearance immersive media experience (video playback, camera) — the HIG's rare-case exception — the reviewer must cite the stated design intent in code comments or project documentation; absent that evidence, fail closed. Scoping a modal media surface dark (e.g. a photo viewer) while the rest of the app adapts is PASS — cite the scope.

**Incorrect (the app ignores the user's systemwide choice):**

```swift
import SwiftUI

@main
struct FieldNotesApp: App {
    var body: some Scene {
        WindowGroup {
            NotebookListView()
                // ⚠️ Pins the whole app light regardless of the user's setting
                .preferredColorScheme(.light)
        }
    }
}
```

**Correct (the app adapts; only the immersive media surface is scoped dark):**

```swift
import SwiftUI

@main
struct FieldNotesApp: App {
    var body: some Scene {
        WindowGroup {
            NotebookListView()
        }
    }
}

struct SpecimenPhotoViewer: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            // Full-bleed photo viewing is the HIG's dark-appearance exception
            .preferredColorScheme(.dark)
    }
}
```

Reference: [HIG — Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
