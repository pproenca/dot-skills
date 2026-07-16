---
title: Bleed backgrounds to the display edges and keep content in the safe area
tags: layout, safe-areas, backgrounds, full-screen
---

## Bleed backgrounds to the display edges and keep content in the safe area

Two symmetric wrong defaults. The first stops a full-screen background or hero image at the safe-area boundary, leaving system-background letterbox bands above and below the artwork. The second over-corrects: `.ignoresSafeArea()` slapped on a whole screen, so text and buttons slide under the Dynamic Island and home indicator. The rule is a split: decorative layers extend to the display edges; text and interactive content never leave the safe area.

**Evidence of violation:** first leg — a full-screen decorative artwork layer (a gradient, `Image`/`AsyncImage`, or `Canvas` composed behind the screen's content in a `ZStack` or `.background { }` closure) with no `.ignoresSafeArea()` or `ignoresSafeAreaEdges:` on that layer; a screenshot showing letterbox bands at the top or bottom of artwork decides this leg when composition in code is ambiguous. A solid single-color fill passed to `.background(_:)` on a content container is NOT evidence for this leg — SwiftUI extends such backgrounds into the safe area ambiguously, so without a screenshot showing bands the leg is N/A, not FAIL (the fill's color choice is `color-system-backgrounds`' business). Second leg — `.ignoresSafeArea()` (or `edgesIgnoringSafeArea`) applied to a subtree that contains `Text` or interactive controls rather than to a background layer alone; cite the modified subtree's contents. PASS: safe-area escape applied only to decorative layers (`.background { gradient.ignoresSafeArea() }`), content left to the default safe-area layout, scrollable content extending under bars via default behavior. N/A: the target has no full-screen backgrounds and no safe-area modifiers. A claimed immersive exception (video playback, camera) must cite the media surface — absent that evidence, fail closed.

**Incorrect (the whole screen escapes, pulling the button under the home indicator):**

```swift
import SwiftUI

struct SunriseHeroView: View {
    let hike: Hike

    var body: some View {
        VStack {
            Spacer()
            Text(hike.name)
                .font(.largeTitle.bold())
            Button("Start Hike") { }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [.orange, .indigo],
                           startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea() // ⚠️ text and button now sit under the home indicator
    }
}
```

**Correct (only the gradient escapes; content stays in the safe area):**

```swift
import SwiftUI

struct SunriseHeroView: View {
    let hike: Hike

    var body: some View {
        VStack {
            Spacer()
            Text(hike.name)
                .font(.largeTitle.bold())
            Button("Start Hike") { }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [.orange, .indigo],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
    }
}
```

Reference: [Human Interface Guidelines — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
