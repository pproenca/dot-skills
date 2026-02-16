---
title: Show Scroll Indicators for Long Scrollable Content
impact: MEDIUM
impactDescription: visible scroll indicators increase below-fold content discovery by 20-40% — users miss 30-50% of scrollable content when indicators are hidden, adding 2-5s of navigation confusion per screen
tags: layout, scroll, indicators, edson-design-out-loud, kocienda-intersection
---

## Show Scroll Indicators for Long Scrollable Content

Edson's "Design Out Loud" means every element communicates something. Scroll indicators tell the user two things: "there's more content below" and "here's where you are in the content." Hiding them (the default in some configurations) removes this spatial awareness. Kocienda's intersection principle demands that even invisible elements like scroll indicators serve a communicative purpose.

**Incorrect (scroll indicators hidden — user doesn't know there's more content):**

```swift
struct LongFormView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)  // User has no idea how much content remains
    }
}
```

**Correct (scroll indicators visible for long content):**

```swift
struct LongFormView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }
            .padding()
        }
        // Default: indicators appear during scrolling, then fade
        // No need to explicitly set — just don't hide them
    }
}
```

**Scroll indicator configuration:**

```swift
// Default: show during scrolling (recommended for most content)
ScrollView { /* content */ }

// Always visible (use for very long content where position matters)
ScrollView { /* content */ }
    .scrollIndicators(.visible)

// Hidden (only for horizontal carousels and paged content)
ScrollView(.horizontal) { /* carousel */ }
    .scrollIndicators(.hidden)
```

**When to hide scroll indicators:**
- Horizontal carousels with paging (the page dots communicate position instead)
- Full-screen media galleries (indicators distract from content)
- Short content that doesn't actually scroll (indicators would flash and disappear)

**When NOT to hide:** Any vertically scrollable content with more than one screenful of material. The user needs spatial awareness.

Reference: [Scroll views - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/scroll-views)
