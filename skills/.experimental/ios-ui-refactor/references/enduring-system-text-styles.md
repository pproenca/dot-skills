---
title: Use Apple Text Styles, Never Fixed Font Sizes
impact: CRITICAL
impactDescription: enables Dynamic Type for roughly a quarter of iOS users who change their default text size, ensures consistent type scale across all screens
tags: enduring, dynamic-type, accessibility, rams-7, edson-conviction, text-styles
---

## Use Apple Text Styles, Never Fixed Font Sizes

Hard-coded font sizes are a snapshot of one moment's aesthetic — they lock your app to today while Apple's type system evolves underneath. When iOS 19 adjusts Dynamic Type curves, apps using `.body` evolve with the platform; apps using `.system(size: 16)` stay frozen. It is the difference between a living typeface that breathes with the OS and a number chiseled into stone. Semantic text styles are not a convenience wrapper — they are a pact with the platform that your typography will age as gracefully as the system itself.

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
