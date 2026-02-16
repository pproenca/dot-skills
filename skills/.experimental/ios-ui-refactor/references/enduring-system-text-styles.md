---
title: Use Apple Text Styles, Never Fixed Font Sizes
impact: CRITICAL
impactDescription: enables Dynamic Type for 25-30% of iOS users who change default text size, ensures consistent type scale across all screens
tags: enduring, dynamic-type, accessibility, rams-7, edson-conviction, text-styles
---

## Use Apple Text Styles, Never Fixed Font Sizes

Rams warned that fashionable design becomes antiquated. Hard-coded font sizes are the typographic equivalent of a trend — they lock your app to one moment's aesthetic while Apple's type system evolves with every OS release. Edson's Design With Conviction means committing to Apple's semantic text styles because they will never be outdated — they are the platform's voice.

**Incorrect (fixed point sizes that bypass Dynamic Type):**

```swift
struct ArticleCard: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.category)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Text(article.title)
                .font(.custom("Helvetica Neue", size: 18))
                .fontWeight(.bold)

            Text(article.excerpt)
                .font(.system(size: 14))
                .lineLimit(3)

            Text(article.author)
                .font(Font.system(size: 12, weight: .medium))
        }
    }
}
```

**Correct (semantic text styles with Dynamic Type support):**

```swift
struct ArticleCard: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.category)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(article.title)
                .font(.headline)

            Text(article.excerpt)
                .font(.body)
                .lineLimit(3)

            Text(article.author)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
```

**Benefits:**
- Dynamic Type scales all text automatically — no manual `@ScaledMetric` plumbing needed.
- Apple's type scale maintains proportional relationships between levels at every accessibility size.
- Eliminates arbitrary font sizes that drift across PRs.

**When NOT to apply:**
- Display text in a branded hero banner may use a fixed size with `@ScaledMetric` for manual scaling. In that case, pair it with `.dynamicTypeSize(...:.accessibility3)` to cap maximum growth and prevent layout breakage.
- Custom typefaces still benefit from text styles: use `Font.custom("YourFont", size: 17, relativeTo: .body)` to get Dynamic Type scaling with a custom face.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
