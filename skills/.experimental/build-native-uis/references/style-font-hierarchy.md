---
title: Use Semantic Font Styles for Typography
impact: HIGH
impactDescription: semantic fonts (.title, .headline, .body) scale with Dynamic Type automatically
tags: style, typography, dynamic-type, accessibility, fonts
---

## Use Semantic Font Styles for Typography

Hardcoded font sizes with `.system(size:)` bypass Dynamic Type, preventing users who rely on larger text from reading your content. Semantic text styles like `.title`, `.headline`, and `.body` communicate typographic hierarchy to the system and scale proportionally with the user's preferred content size.

**Incorrect (hardcoded font sizes that ignore Dynamic Type):**

```swift
struct ArticleCard: View {
    let title: String
    let author: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 24, weight: .bold)) // fixed size, ignores Dynamic Type
            Text("By \(author)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text(summary)
                .font(.system(size: 16))
                .lineLimit(3)
        }
        .padding()
    }
}
```

**Correct (semantic font styles that scale with Dynamic Type):**

```swift
struct ArticleCard: View {
    let title: String
    let author: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.bold()) // scales with Dynamic Type
            Text("By \(author)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(summary)
                .font(.body) // matches user's preferred reading size
                .lineLimit(3)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
