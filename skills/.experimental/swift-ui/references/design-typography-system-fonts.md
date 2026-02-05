---
title: Use System Typography Styles
impact: CRITICAL
impactDescription: ensures Dynamic Type support and visual consistency
tags: design, typography, fonts, dynamic-type, hig
---

## Use System Typography Styles

Apple's semantic font styles (`.title`, `.headline`, `.body`) automatically scale with Dynamic Type and maintain visual hierarchy. Hardcoded sizes break accessibility.

**Incorrect (hardcoded font sizes):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.system(size: 24, weight: .bold))  // Ignores Dynamic Type
            Text(article.subtitle)
                .font(.system(size: 16))  // Fixed size
            Text(article.body)
                .font(.system(size: 14))  // Won't scale
        }
    }
}
```

**Correct (semantic text styles):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.title)  // Scales with Dynamic Type
            Text(article.subtitle)
                .font(.headline)  // Semantic meaning
            Text(article.body)
                .font(.body)  // Default reading size
        }
    }
}
```

**Text style hierarchy:**

```swift
.largeTitle  // 34pt - Screen titles
.title       // 28pt - Section headers
.title2      // 22pt - Subsections
.title3      // 20pt - Group headers
.headline    // 17pt semibold - Important labels
.body        // 17pt - Default text
.callout     // 16pt - Secondary content
.subheadline // 15pt - Supporting text
.footnote    // 13pt - Disclaimers
.caption     // 12pt - Labels
.caption2    // 11pt - Smallest text
```

**Customizing while preserving scaling:**

```swift
Text("Custom Title")
    .font(.title.weight(.heavy))
    .font(.body.italic())
    .font(.headline.monospaced())
```

Reference: [Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
