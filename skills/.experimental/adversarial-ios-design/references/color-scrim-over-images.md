---
title: Separate text from imagery with a legibility layer
tags: color, scrim, materials, legibility
---

## Separate text from imagery with a legibility layer

The wrong default for a hero card or photo header is white text composited straight onto the image. It reads on the dusk skyline the author chose and fails on the snow scene the user uploads — text over uncontrolled imagery has no contrast guarantee. Apple's pattern is a legibility layer between the two: a gradient scrim, a dimming fill, or a material. The same page names the number for the glass case: clear-variant Liquid Glass over media needs a dark dimming layer of about 35% opacity when the content beneath can be bright.

**Evidence of violation:** a `Text` composited over an `Image`/`AsyncImage` — via `ZStack` ordering or `.overlay` — with no intervening `LinearGradient` scrim, dimming `Color` fill, or material layer between the image and the text; cite the composition. Glass leg: `glassEffect(.clear)` (or a clear-variant glass control) over photo or video content with no dimming layer. PASS: a scrim/gradient/dim/material layer sits between image and text — cite the layer; or provided screenshots demonstrate the text region meets the contrast floors of `color-contrast-floors` across both appearances — cite the measurement. N/A: text over a solid color or material rather than imagery; no text-over-image composition in the target.

**Incorrect (white caption straight on user-supplied artwork — no contrast guarantee):**

```swift
import SwiftUI

struct ArtworkHeroCard: View {
    let listing: ArtListing

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: listing.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color(.secondarySystemBackground)
            }
            VStack(alignment: .leading) { // ⚠️ text sits directly on the image — vanishes over bright artwork
                Text(listing.title).font(.title2.bold())
                Text(listing.artistName).font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(.rect(cornerRadius: 16))
    }
}
```

**Correct (a gradient scrim guarantees the pairing on any artwork):**

```swift
import SwiftUI

struct ArtworkHeroCard: View {
    let listing: ArtListing

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: listing.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color(.secondarySystemBackground)
            }
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )
            VStack(alignment: .leading) {
                Text(listing.title).font(.title2.bold())
                Text(listing.artistName).font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(.rect(cornerRadius: 16))
    }
}
```

Reference: [Human Interface Guidelines — Materials](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC25 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
