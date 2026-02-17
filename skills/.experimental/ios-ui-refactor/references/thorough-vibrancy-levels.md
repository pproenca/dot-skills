---
title: Match Vibrancy Level to Content Importance
impact: HIGH
impactDescription: flat-vibrancy text over materials forces users to read every label at the same visual weight — proper vibrancy hierarchy reduces scanning time
tags: thorough, vibrancy, hierarchy, rams-8, rams-2, materials
---

## Match Vibrancy Level to Content Importance

A now-playing card where every label is the same visual weight over a material blur — track name, artist, album all rendered in `.primary` — is a card where nothing stands out. The user reads everything instead of scanning, because the hierarchy that should guide the eye from title to detail to metadata simply does not exist. Vibrancy levels (`.primary`, `.secondary`, `.tertiary`) are the tool the platform gives you to create that hierarchy over translucent surfaces. Using `.primary` for everything is like setting every word in a sentence to bold: technically readable, but the emphasis — and with it the meaning — is gone.

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

**When NOT to apply:** Content over solid, opaque backgrounds where vibrancy provides no visual benefit -- use standard `.foregroundStyle(.primary/.secondary/.tertiary)` without material, as vibrancy levels only produce meaningful hierarchy differences over translucent surfaces.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
