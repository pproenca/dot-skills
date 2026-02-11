---
title: Match Vibrancy Level to Content Importance
impact: HIGH
impactDescription: flat-vibrancy text over materials forces users to read every label at the same visual weight — proper vibrancy hierarchy reduces scanning time by establishing importance without custom colors, across all appearances
tags: depth, vibrancy, hierarchy, materials, readability, text
---

## Match Vibrancy Level to Content Importance

When every label over a material uses `.foregroundStyle(.primary)`, the material does its job but the text layer fails at hierarchy. iOS materials are designed to work with the four vibrancy levels — `.primary`, `.secondary`, `.tertiary`, and `.quaternary` — which map directly to content importance. These levels adjust opacity, blur contribution, and saturation automatically so that text remains readable over any material thickness in any appearance mode. Skipping this system and using hard-coded opacity values (`Color.white.opacity(0.6)`) breaks vibrancy entirely because those colors bypass the material compositing pipeline.

**Incorrect (uniform vibrancy — no content hierarchy over material):**

```swift
struct NowPlayingCard: View {
    let trackName: String
    let artistName: String
    let albumName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(trackName)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(artistName)
                .font(.subheadline)
                // Same visual weight as the track name
                .foregroundStyle(.primary)

            Text(albumName)
                .font(.caption)
                // Hard-coded opacity — not vibrancy-aware
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(.regularMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (vibrancy levels match content importance):**

```swift
struct NowPlayingCard: View {
    let trackName: String
    let artistName: String
    let albumName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(trackName)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(artistName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(albumName)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Vibrancy hierarchy mapping:**
- `.primary` — title, key value, primary action label. Full prominence.
- `.secondary` — supporting description, subtitle, secondary metrics. Noticeably receded.
- `.tertiary` — supplementary metadata, timestamps, footnotes. Background-level.
- `.quaternary` — decorative elements, separator lines, placeholder icons. Near-invisible by design.

**Alternative:** For tinted labels over materials (e.g., a status badge), use `.foregroundStyle(.blue)` directly — SwiftUI automatically applies the correct vibrancy treatment when the view sits inside a material background.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
