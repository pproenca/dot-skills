---
title: Use System Typography Styles, Never Fixed Sizes
impact: CRITICAL
impactDescription: hardcoded font sizes bypass Dynamic Type for 100% of users who adjust text size — breaking accessibility for the 25% of users who increase their default text size
tags: system, typography, dynamic-type, kocienda-convergence, edson-systems, font
---

## Use System Typography Styles, Never Fixed Sizes

Edson's systems thinking demands that typography be a system, not a collection of ad hoc sizes. Apple's semantic text styles — `.title`, `.headline`, `.body` — are that system: each style has a defined relationship to every other, and all of them scale together when the user adjusts Dynamic Type. Kocienda's convergence principle applies directly — the iPhone team tried dozens of font sizes before converging on the San Francisco type scale that works across every device and context. When you hardcode `.system(size: 24)`, you opt out of that convergence and force the user to accept your font size regardless of their vision or preference.

**Incorrect (hardcoded font sizes break Dynamic Type):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.system(size: 24, weight: .bold))

            Text(article.subtitle)
                .font(.custom("Helvetica", size: 16))

            Text(article.body)
                .font(.system(size: 14))
        }
    }
}
```

**Correct (semantic text styles that scale with Dynamic Type):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.title)

            Text(article.subtitle)
                .font(.headline)

            Text(article.body)
                .font(.body)
        }
    }
}
```

**Text style hierarchy:**

| Style | Default Size | Usage |
|-------|-------------|-------|
| `.largeTitle` | 34pt | Main screen titles |
| `.title` | 28pt | Section titles |
| `.title2` | 22pt | Subsection titles |
| `.title3` | 20pt | Smaller titles |
| `.headline` | 17pt semibold | Section headers |
| `.body` | 17pt | Primary content |
| `.callout` | 16pt | Secondary content |
| `.subheadline` | 15pt | Labels, metadata |
| `.footnote` | 13pt | Supplementary text |
| `.caption` | 12pt | Timestamps, tags |
| `.caption2` | 11pt | Legal text, minimums |

**Customizing while preserving scaling:**

```swift
Text("Heavy Title")
    .font(.title.weight(.heavy))

Text("Italic Body")
    .font(.body.italic())

Text("Mono Headline")
    .font(.headline.monospaced())
```

**When NOT to use system styles:** Display text in marketing screens or onboarding illustrations where a custom typeface is part of the brand identity. Even then, use `UIFontMetrics` to scale custom fonts with Dynamic Type.

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
