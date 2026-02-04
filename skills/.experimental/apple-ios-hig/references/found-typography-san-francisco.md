---
title: Use San Francisco System Font with Text Styles
impact: CRITICAL
impactDescription: enables Dynamic Type and consistent typography
tags: found, font, text-style, dynamic-type
---

## Use San Francisco System Font with Text Styles

Use iOS text styles (`.title`, `.body`, `.caption`) instead of fixed font sizes. Text styles use San Francisco system font and automatically scale with Dynamic Type accessibility settings.

**Incorrect (fixed sizes break Dynamic Type):**

```swift
// SwiftUI
Text("Title")
    .font(.system(size: 28, weight: .bold))
Text("Body text")
    .font(.custom("Helvetica", size: 16))

// UIKit
label.font = UIFont.systemFont(ofSize: 17)
```

**Correct (text styles scale with user preferences):**

```swift
// SwiftUI
Text("Title")
    .font(.largeTitle)
Text("Section Header")
    .font(.headline)
Text("Body text")
    .font(.body)
Text("Supporting info")
    .font(.footnote)

// UIKit
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
```

**iOS text style hierarchy:**
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

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
