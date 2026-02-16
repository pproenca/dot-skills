---
title: Use System Standard Margins Consistently
impact: HIGH
impactDescription: centralizing margins into a single constant eliminates 10-30 ad-hoc padding values across a typical app — reduces layout inconsistency bugs by 80-90% and saves 2-5 lines per screen vs scattered hardcoded values
tags: system, margins, padding, kocienda-convergence, edson-systems, layout
---

## Use System Standard Margins Consistently

Edson's systems thinking demands that margins be part of the spatial system, not decided screen by screen. Apple uses consistent horizontal margins across every system app — 16pt on iPhone, adapting with size class on iPad. Kocienda's convergence applies: when every screen uses the same margins, they converge into one coherent spatial experience. When one screen uses 12pt, another 20pt, and a third 16pt, the user perceives three different apps.

**Incorrect (inconsistent margins across screens):**

```swift
// Screen A
.padding(.horizontal, 12)

// Screen B
.padding(.horizontal, 20)

// Screen C
.padding(.horizontal, 16)

// Screen D
.padding(.leading, 15)
.padding(.trailing, 18)
```

**Correct (consistent system margins):**

```swift
// Define once, use everywhere
enum AppLayout {
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

// Every content screen
struct RecipeListView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recipes) { recipe in
                    RecipeCard(recipe: recipe)
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
        }
    }
}

// Or use scenePadding for automatic adaptation
struct AdaptiveContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // content
            }
            .scenePadding(.horizontal)
        }
    }
}
```

**System margin conventions:**
| Context | Margin | API |
|---------|--------|-----|
| Standard content | 16pt | `.padding(.horizontal, 16)` |
| List/Form insets | System-managed | Automatic via `List` |
| Scene-adaptive | Varies by size class | `.scenePadding(.horizontal)` |
| Readable content | ≤672pt centered | `.frame(maxWidth: 672)` |

**When NOT to enforce custom margins:** `List`, `Form`, and `NavigationStack` manage their own margins. Don't add `.padding(.horizontal)` to content inside these containers — it doubles the inset.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
