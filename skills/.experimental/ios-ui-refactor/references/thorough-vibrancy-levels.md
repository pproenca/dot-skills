---
title: Match Vibrancy Level to Content Importance
impact: HIGH
impactDescription: flat-vibrancy text over materials forces users to read every label at the same visual weight — proper vibrancy hierarchy reduces scanning time
tags: thorough, vibrancy, hierarchy, rams-8, rams-2, materials
---

## Match Vibrancy Level to Content Importance

Rams' thoroughness means every detail serves the user. Vibrancy levels (.primary, .secondary, .tertiary) exist to create hierarchy over materials — using .primary for everything is leaving a system-provided tool unused. Rams' #2: the product is more useful when the hierarchy is visible without the user deciphering uniform text.

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
