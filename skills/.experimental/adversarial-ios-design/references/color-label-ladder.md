---
title: Express text hierarchy with the semantic label ladder
tags: color, labels, hierarchy, vibrancy
---

## Express text hierarchy with the semantic label ladder

The wrong default for de-emphasizing text is `Color.gray`, `.opacity(0.6)`, or a hand-mixed `Color(white: 0.45)`. A flat gray is one value in both appearances: it sits too dark on dark backgrounds, too light on some light surfaces, and never picks up the vibrancy treatment text gets when it lands on a material. The label ladder — `.secondary`, `.tertiary`, `.quaternary` hierarchical styles, or `Color(.secondaryLabel)` and friends — encodes the same hierarchy while adapting per appearance, per elevation, and per material automatically.

**Evidence of violation:** `.foregroundStyle(Color.gray)` / `.foregroundColor(.gray)`, `.opacity(0.x)` applied to a `Text` or label to de-emphasize it, or `Color(white:)` / gray-valued custom colors styled onto text where a label-ladder step serves the same role. PASS: `.secondary` / `.tertiary` / `.quaternary` hierarchical styles or the `Color(.secondaryLabel)` family on supporting text. N/A: gray as a chromatic choice in decorative, non-textual artwork — the reviewer must cite the decorative context; absent that evidence, fail closed. N/A: no de-emphasized text in the target.

**Incorrect (one flat gray in both appearances, no vibrancy on materials):**

```swift
import SwiftUI

struct EpisodeRow: View {
    let episode: PodcastEpisode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(episode.title)
                .font(.headline)
            Text(episode.showName)
                .font(.subheadline)
                .foregroundStyle(Color.gray) // ⚠️ flat gray — muddy on dark, dead on materials
            Text(episode.duration, format: .units(allowed: [.hours, .minutes]))
                .font(.caption)
                .opacity(0.6) // ⚠️ opacity de-emphasis instead of the label ladder
        }
    }
}
```

**Correct (the ladder adapts per appearance, elevation, and material):**

```swift
import SwiftUI

struct EpisodeRow: View {
    let episode: PodcastEpisode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(episode.title)
                .font(.headline)
            Text(episode.showName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(episode.duration, format: .units(allowed: [.hours, .minutes]))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
```

Reference: [Human Interface Guidelines — Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode), [Human Interface Guidelines — Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
