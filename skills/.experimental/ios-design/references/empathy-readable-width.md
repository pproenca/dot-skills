---
title: Constrain Text to Readable Width on iPad
impact: HIGH
impactDescription: lines exceeding 80 characters force the eye to lose its place on the return sweep — reducing reading speed by 20% and comprehension by 15% on wide iPad displays
tags: empathy, readable, width, kocienda-empathy, edson-people, ipad, typography
---

## Constrain Text to Readable Width on iPad

Kocienda's empathy extends beyond the iPhone — when the iPad launched, the same keyboard concepts had to adapt to a radically wider canvas. Text that stretches edge-to-edge on a 12.9" iPad Pro forces the reader's eye to travel so far that it loses its place on the return sweep to the next line. This is not a typography preference — it is a cognitive reality that Edson's people-first design demands we respect. The `.readableContentGuide` and `.dynamicTypeSize` tools exist because Apple's own teams discovered this problem and built the solution into UIKit and SwiftUI.

**Incorrect (text stretches full width on iPad):**

```swift
struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.largeTitle.bold())

                Text(article.body)
                    .font(.body)
            }
            // On 12.9" iPad, lines stretch to ~150 characters
            .padding(.horizontal, 16)
        }
    }
}
```

**Correct (constrained to readable width):**

```swift
struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.largeTitle.bold())

                Text(article.body)
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 672, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}
```

**Alternative using the dynamic readable guide:**

```swift
// In a UIKit-backed layout
.frame(maxWidth: .readableContentWidth)

// Or constrain within a List/Form which automatically uses readableContentGuide
List {
    Section {
        Text(article.body)
    }
}
.listStyle(.insetGrouped)
```

**Readable width guidelines:**
- 50-80 characters per line is the optimal range for body text
- 672pt ≈ 80 characters in `.body` at default Dynamic Type size
- `List` and `Form` automatically constrain to readable width on iPad
- Use `.scenePadding(.horizontal)` for automatic horizontal padding that adapts to size class

**When NOT to constrain:** Full-bleed media (images, maps, video), grid layouts, and dashboard cards should use the full available width. Only constrain running text.

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography), [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
