---
title: Use System Typography Styles
impact: CRITICAL
impactDescription: prevents accessibility failures from hardcoded font sizes; enables automatic Dynamic Type scaling across 11+ text styles
tags: design, typography, fonts, dynamic-type, hig, text-style
---

## Use System Typography Styles

Apple's semantic font styles (`.title`, `.headline`, `.body`) use the San Francisco system font and automatically scale with Dynamic Type. Hardcoded sizes break accessibility.

**Incorrect (hardcoded font sizes):**

```swift
// SwiftUI
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.system(size: 24, weight: .bold))  // Ignores Dynamic Type
            Text(article.subtitle)
                .font(.custom("Helvetica", size: 16))  // Fixed size
            Text(article.body)
                .font(.system(size: 14))  // Won't scale
        }
    }
}

// UIKit
label.font = UIFont.systemFont(ofSize: 17)
```

**Correct (semantic text styles):**

```swift
// SwiftUI
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

// UIKit
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
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

Reference: [Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
